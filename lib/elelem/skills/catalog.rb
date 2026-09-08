# frozen_string_literal: true

module Elelem
  module Skills
    class Catalog
      LOAD_PATHS = [
        "~/.agents/skills",
        ".agents/skills"
      ].freeze

      def initialize(load_paths: LOAD_PATHS)
        @load_paths = load_paths
      end

      def all
        @all ||= discover
      end

      def find(name)
        all.find { |skill| skill.name == name }
      end

      def index(limit: nil)
        summaries = all.map(&:summary)
        summaries = summaries.map { |text| truncate(text, limit) } if limit
        summaries.join("\n")
      end

      private

      def discover
        seen = {}

        @load_paths.each do |path|
          dir = File.expand_path(path)
          next unless File.directory?(dir)

          Dir["#{dir}/*/SKILL.md"].sort.each do |skill_md|
            skill = SkillFile.load(skill_md)
            next unless skill

            seen[skill.name] = skill
          rescue => e
            Elelem.logger.warn("elelem-skills: failed to load #{skill_md}: #{e.message}")
          end
        end

        seen.values
      end

      def truncate(text, limit)
        return text if text.length <= limit

        "#{text[0, limit]}..."
      end
    end
  end
end
