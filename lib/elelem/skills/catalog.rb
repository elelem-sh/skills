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

      def each(&block)
        all.each(&block)
      end

      private

      def discover(seen = {})
        @load_paths.each do |path|
          dir = File.expand_path(path)
          next unless File.directory?(dir)

          Dir["#{dir}/*/SKILL.md"].sort.each do |skill_md|
            skill = Skill.load(skill_md)
            next unless skill

            seen[skill.name] = skill
          rescue => e
            Elelem.logger.warn("elelem-skills: failed to load #{skill_md}: #{e.message}")
          end
        end

        seen.values
      end
    end
  end
end
