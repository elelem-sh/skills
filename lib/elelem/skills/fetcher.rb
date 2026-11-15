# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "net/http"
require "uri"

module Elelem
  module Skills
    class Fetcher
      SCHEMA = "https://schemas.agentskills.io/discovery/0.2.0/schema.json"
      MAX_REDIRECTS = 5

      class FetchError < StandardError
      end

      def initialize(install_dir: Catalog::REMOTE_SKILLS, http: Net::HTTP, lockfile: nil)
        @install_dir = install_dir
        @http = http
        @lockfile = lockfile || Lockfile.new(File.join(install_dir, ".skill-lock.json"))
      end

      # Fetches https://<origin>/.well-known/agent-skills/index.json
      def fetch(origin)
        base = normalize(origin)
        index, index_url = get_json(URI.join(base, "/.well-known/agent-skills/index.json"))

        unless index["$schema"] == SCHEMA
          raise FetchError, "unrecognized index schema #{index["$schema"].inspect} at #{index_url} (expected #{SCHEMA})"
        end

        host = sanitize(base.host)
        host_dir = File.join(@install_dir, host)
        (index["skills"] || []).filter_map { |entry| install(entry, index_url, host, host_dir) }
      end

      private

      def normalize(origin)
        origin = "https://#{origin}" unless origin.start_with?("http://", "https://")
        URI.parse(origin)
      end

      def sanitize(host)
        host.to_s.downcase.gsub(/[^a-z0-9.-]/, "_")
      end

      def install(entry, index_url, host, host_dir)
        name, type, url, digest = entry.values_at("name", "type", "url", "digest")

        unless type == "skill-md"
          Elelem.logger.warn("elelem-skills: fetch: skipping #{name.inspect}, unsupported type #{type.inspect} " \
                             "(archives are not implemented)")
          return nil
        end

        skill_url = URI.join(index_url, url)
        body, = get(skill_url)
        verify!(name, body, digest)

        dir = File.join(host_dir, sanitize(name))
        FileUtils.mkdir_p(dir)
        File.write(File.join(dir, "SKILL.md"), body)
        @lockfile.record(host: host, name: name, url: skill_url.to_s, digest: digest)

        name
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

        target = URI.join(uri, response["location"].to_s)
        if uri.scheme == "https" && target.scheme != "https"
          raise FetchError, "GET #{uri}: refusing redirect from https to #{target}"
        end

        get(target, hops: hops - 1)
      end
    end
  end
end
