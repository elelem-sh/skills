# frozen_string_literal: true

require "fileutils"
require "json"
require "time"

module Elelem
  module Skills
    class Lockfile
      VERSION = 1

      def initialize(path)
        @path = path
      end

      def record(host:, name:, url:, digest:)
        data = read
        key = "#{host}/#{name}"
        now = Time.now.utc.iso8601
        installed_at = data.dig("skills", key, "installedAt") || now

        data["skills"][key] = {
          "host" => host,
          "name" => name,
          "url" => url,
          "digest" => digest,
          "installedAt" => installed_at,
          "updatedAt" => now
        }

        write(data)
      end

      def digest_for(host:, name:)
        read.dig("skills", "#{host}/#{name}", "digest")
      end

      def read
        return { "version" => VERSION, "skills" => {} } unless File.exist?(@path)

        data = JSON.parse(File.read(@path))
        data["skills"] ||= {}
        data
      rescue JSON::ParserError
        { "version" => VERSION, "skills" => {} }
      end

      private

      def write(data)
        FileUtils.mkdir_p(File.dirname(@path))
        File.write(@path, JSON.pretty_generate(data))
      end
    end
  end
end
