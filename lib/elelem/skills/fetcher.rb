# frozen_string_literal: true

require "digest"
require "fileutils"
require "ipaddr"
require "json"
require "net/http"
require "uri"

module Elelem
  module Skills
    class Fetcher
      SCHEMA = "https://schemas.agentskills.io/discovery/0.2.0/schema.json"
      MAX_REDIRECTS = 5
      LOCAL_NAMES = %w[localhost].freeze

      class FetchError < StandardError
      end

      def initialize(install_dir: Catalog::REMOTE_SKILLS, http: Net::HTTP, lockfile: nil)
        @install_dir = install_dir
        @http = http
        @lockfile = lockfile || Lockfile.new(File.join(install_dir, ".skill-lock.json"))
      end

      # Fetches https://<origin>/.well-known/agent-skills/index.json
      # Skills whose pinned digest changed in the last fetch, as "host/name".
      attr_reader :changed

      def fetch(origin)
        base = normalize(origin)
        @changed = []
        # Only an origin on this machine may lead to this machine.
        @local_origin = local?(base)
        index, index_url = get_json(URI.join(base, "/.well-known/agent-skills/index.json"))

        unless index["$schema"] == SCHEMA
          raise FetchError, "unrecognized index schema #{index["$schema"].inspect} at #{index_url} (expected #{SCHEMA})"
        end

        host = sanitize(base.host)
        # Download and check every skill before writing any, so a bad one
        # leaves nothing half installed.
        downloads = (index["skills"] || []).filter_map { |entry| download(entry, index_url) }
        downloads.each { |skill| install(skill, host) }
        downloads.map { |skill| skill[:name] }
      end

      private

      def normalize(origin)
        origin = "https://#{origin}" unless origin.start_with?("http://", "https://")
        URI.parse(origin)
      end

      def sanitize(host)
        host.to_s.downcase.gsub(/[^a-z0-9.-]/, "_")
      end

      def download(entry, index_url)
        name, type, url, digest = entry.values_at("name", "type", "url", "digest")

        unless type == "skill-md"
          Elelem.logger.warn("elelem-skills: fetch: skipping #{name.inspect}, unsupported type #{type.inspect} " \
                             "(archives are not implemented)")
          return nil
        end
        raise FetchError, "#{name.inspect} has no digest, so it cannot be checked" if digest.to_s.empty?

        skill_url = URI.join(index_url, url)
        body, = get(skill_url)
        verify!(name, body, digest)
        { name: name, url: skill_url.to_s, digest: digest, body: body }
      end

      def install(skill, host)
        warn_if_changed(skill, host)
        dir = File.join(@install_dir, host, sanitize(skill[:name]))
        FileUtils.mkdir_p(dir)
        # Write beside the file, then rename, so a reader never sees half of it.
        tmp = File.join(dir, ".SKILL.md.#{Process.pid}")
        File.binwrite(tmp, skill[:body])
        File.rename(tmp, File.join(dir, "SKILL.md"))
        @lockfile.record(host: host, name: skill[:name], url: skill[:url], digest: skill[:digest])
      end

      # The first fetch pins a digest. A later, different one is installed, but said out loud.
      def warn_if_changed(skill, host)
        pinned = @lockfile.digest_for(host: host, name: skill[:name])
        return if pinned.nil? || pinned == skill[:digest]

        Elelem.logger.warn("elelem-skills: #{host}/#{skill[:name]} changed: was #{pinned}, now #{skill[:digest]}")
        @changed << "#{host}/#{skill[:name]}"
      end

      def verify!(name, body, digest)
        expected = digest.to_s.delete_prefix("sha256:")
        actual = Digest::SHA256.hexdigest(body)
        return if expected == actual

        raise FetchError, "digest mismatch for #{name.inspect}: expected sha256:#{expected}, got sha256:#{actual}"
      end

      # Returns the parsed body and the URL it came from after any redirects, so
      # relative skill URLs resolve against where the index really is.
      def get_json(uri)
        body, final = get(uri)
        [JSON.parse(body), final]
      rescue JSON::ParserError => e
        raise FetchError, "invalid JSON at #{uri}: #{e.message}"
      end

      def get(uri, hops: MAX_REDIRECTS)
        raise FetchError, "refusing #{uri}: use https" unless secure?(uri)

        response = @http.get_response(uri)
        return redirect(uri, response, hops) if response.is_a?(Net::HTTPRedirection)
        raise FetchError, "GET #{uri} -> #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

        [response.body, uri]
      rescue FetchError
        raise
      rescue StandardError => e
        raise FetchError, "GET #{uri} failed: #{e.class}: #{e.message}"
      end

      def redirect(uri, response, hops)
        raise FetchError, "GET #{uri}: too many redirects" if hops.zero?

        get(URI.join(uri, response["location"].to_s), hops: hops - 1)
      end

      # This machine, by address rather than spelling: 127.0.0.2, 127.1,
      # [0:0::1], ::ffff:127.0.0.1, 0.0.0.0 and LOCALHOST. all count.
      def local?(uri)
        name = uri.hostname.to_s.downcase.chomp(".")
        return true if LOCAL_NAMES.include?(name) || name.end_with?(".localhost")

        address = IPAddr.new(name)
        address = address.native if address.ipv4_mapped?
        address.loopback? || address.to_i.zero?
      rescue IPAddr::InvalidAddressError
        false
      end

      # https, or plain http for a skill server on this machine. A remote index
      # cannot redirect to this machine, http or https.
      def secure?(uri)
        local = local?(uri)
        return false if local && !@local_origin

        uri.scheme == "https" || (uri.scheme == "http" && local)
      end
    end
  end
end
