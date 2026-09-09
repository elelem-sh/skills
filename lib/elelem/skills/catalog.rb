# frozen_string_literal: true

module Elelem
  module Skills
    class Catalog
      REMOTE_SKILLS = File.expand_path("~/.agents/remote-skills").freeze

      LOAD_PATHS = [
        "~/.agents/skills",
        ".agents/skills"
      ].freeze

      def initialize(load_paths: LOAD_PATHS, remote_skills: REMOTE_SKILLS)
        @load_paths = load_paths
        @remote_skills = remote_skills
      end

      def all(reload: false)
        @all = nil if reload
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

        scan_remote(seen) if @remote_skills
        @load_paths.each { |path| scan_one_level(path, seen) }

        seen.values
      end

      def scan_one_level(path, seen)
        dir = File.expand_path(path)
        return unless File.directory?(dir)

        Dir["#{dir}/*/SKILL.md"].sort.each { |skill_md| load_into(skill_md, seen) }
      end

      def scan_remote(seen)
        dir = File.expand_path(@remote_skills)
        return unless File.directory?(dir)

        Dir["#{dir}/*/*/SKILL.md"].sort.each { |skill_md| load_into(skill_md, seen) }
      end

      def load_into(skill_md, seen)
        skill = SkillFile.load(skill_md)
        return unless skill

        seen[skill.name] = skill
      rescue => e
        Elelem.logger.warn("elelem-skills: failed to load #{skill_md}: #{e.message}")
      end

      def truncate(text, limit)
        return text if text.length <= limit

        "#{text[0, limit]}..."
      end
    end
  end
end
