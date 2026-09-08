# frozen_string_literal: true

module Elelem
  module Skills
    class Setup
      SUMMARY_LIMIT = 400

      def self.call(agent)
        new(agent, Catalog.new).call
      end

      def initialize(agent, catalog)
        @agent = agent
        @catalog = catalog
      end

      def call
        return if @catalog.all.empty?

        register_tool
        register_command
      end

      private

      def register_tool
        catalog = @catalog

        @agent.toolbox.add("skill",
          description: "Load a skill's instructions by name. Available skills:\n#{catalog.index(limit: SUMMARY_LIMIT)}",
          params: { name: { type: "string", description: "the skill name" } },
          required: ["name"]
        ) do |a|
          skill = catalog.find(a["name"])
          next { error: "unknown skill: #{a["name"]}" } unless skill

          { name: skill.name, dir: skill.dir, content: skill.body }
        end
      end

      def register_command
        catalog = @catalog
        agent = @agent
        completions = -> { catalog.all.map(&:name) }

        agent.commands.register("skills", description: "List available skills", completions: completions) do |arg|
          if arg && !arg.empty?
            skill = catalog.find(arg)
            skill ? agent.output.say(skill.body) : agent.output.say("Unknown skill: #{arg}")
          else
            agent.output.say(catalog.index)
          end
        end
      end
    end
  end
end

Elelem.configure do |config|
  config.setup(:skills) { |agent| Elelem::Skills::Setup.call(agent) }
end
