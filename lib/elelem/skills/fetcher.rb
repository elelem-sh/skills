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

      FetchError = Class.new(StandardError)

      def initialize(install_dir: Catalog::REMOTE_SKILLS, http: Net::HTTP)
        @install_dir = install_dir
        @http = http
      end

      # Fetches https://<origin>/.well-known/agent-skills/index.json, verifies
      # it, and installs every type: "skill-md" entry into
      # install_dir/<index host>/<skill name>/SKILL.md. Partitioning by the
      # index's own host (not the artifact URL's host, which the spec allows
      # to point elsewhere, e.g. a CDN) keeps two publishers who happen to
      # both name a skill "wrangler" from clobbering each other on disk --
      # Catalog still resolves by frontmatter name across all of them, so a
      # same-named skill from two hosts is still ambiguous at that level;
      # this only fixes the fetch-time file collision, not that ambiguity.
      # Entries with an unsupported type (currently anything but "skill-md")
      # are skipped with a warning, per the spec's guidance.
      #
      # Returns the list of skill names installed.
      def fetch(origin)
        base = normalize(origin)
        index_url = URI.join(base, "/.well-known/agent-skills/index.json")
        index = get_json(index_url)

        unless index["$schema"] == SCHEMA
          raise FetchError, "unrecognized index schema #{index["$schema"].inspect} at #{index_url} (expected #{SCHEMA})"
        end

        host_dir = File.join(@install_dir, sanitize(base.host))
        (index["skills"] || []).filter_map { |entry| install(entry, index_url, host_dir) }
      end

      private

      def normalize(origin)
        origin = "https://#{origin}" unless origin.start_with?("http://", "https://")
        URI.parse(origin)
      end

      def sanitize(host)
        host.to_s.downcase.gsub(/[^a-z0-9.-]/, "_")
      end

      def install(entry, index_url, host_dir)
        name, type, url, digest = entry.values_at("name", "type", "url", "digest")

        unless type == "skill-md"
          Elelem.logger.warn("elelem-skills: fetch: skipping #{name.inspect}, unsupported type #{type.inspect} (archives are not implemented)")
          return nil
        end

        body = get_raw(URI.join(index_url, url))
        verify!(name, body, digest)

        dir = File.join(host_dir, sanitize(name))
        FileUtils.mkdir_p(dir)
        File.write(File.join(dir, "SKILL.md"), body)

        name
      end

      def verify!(name, body, digest)
        expected = digest.to_s.delete_prefix("sha256:")
        actual = Digest::SHA256.hexdigest(body)
        return if expected == actual

        raise FetchError, "digest mismatch for #{name.inspect}: expected sha256:#{expected}, got sha256:#{actual}"
      end

      def get_json(uri)
        JSON.parse(get_raw(uri))
      rescue JSON::ParserError => e
        raise FetchError, "invalid JSON at #{uri}: #{e.message}"
      end

      def get_raw(uri)
        response = @http.get_response(uri)
        raise FetchError, "GET #{uri} -> #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

        response.body
      rescue FetchError
        raise
      rescue => e
        raise FetchError, "GET #{uri} failed: #{e.class}: #{e.message}"
      end
    end
  end
end
