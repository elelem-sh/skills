# frozen_string_literal: true

module Elelem
  module Skills
    module SkillFile
      def self.load(path)
        parse(File.read(path), path: path)
      end

      def self.parse(text, path:)
        frontmatter, body = split(text)
        unless frontmatter
          Elelem.logger.warn("elelem-skills: #{path} has no frontmatter, skipping")
          return nil
        end

        attrs = YAML.safe_load(frontmatter)
        name, description = attrs["name"], attrs["description"]
        unless name && description
          Elelem.logger.warn("elelem-skills: #{path} is missing name or description, skipping")
          return nil
        end

        Skill.new(name, description, File.dirname(path), body.strip)
      end

      def self.split(text)
        return [nil, text] unless text.start_with?("---\n")

        _, frontmatter, body = text.split(/^---\s*$/, 3)
        return [nil, text] unless frontmatter && body

        [frontmatter, body]
      end
      private_class_method :split
    end
  end
end
