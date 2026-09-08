# frozen_string_literal: true

module Elelem
  module Skills
    class Skill
      SUMMARY_LIMIT = 400

      attr_reader :name, :description, :dir, :path, :body

      def initialize(name:, description:, dir:, path:, body:)
        @name = name
        @description = description
        @dir = dir
        @path = path
        @body = body
      end

      def self.truncate(text, limit: SUMMARY_LIMIT)
        return text if text.length <= limit

        "#{text[0, limit]}..."
      end

      def self.load(skill_md)
        frontmatter, body = split(File.read(skill_md))
        unless frontmatter
          Elelem.logger.warn("elelem-skills: #{skill_md} has no frontmatter, skipping")
          return nil
        end

        attrs = YAML.safe_load(frontmatter)
        name, description = attrs["name"], attrs["description"]
        unless name && description
          Elelem.logger.warn("elelem-skills: #{skill_md} is missing name or description, skipping")
          return nil
        end

        new(name: name, description: description, dir: File.dirname(skill_md), path: skill_md, body: body.strip)
      end

      def self.split(text)
        return [nil, text] unless text.start_with?("---\n")

        _, frontmatter, body = text.split(/^---\s*$/, 3)
        return [nil, text] unless frontmatter && body

        [frontmatter, body]
      end
      private_class_method :split

      def summary
        "#{name}: #{description}"
      end
    end
  end
end
