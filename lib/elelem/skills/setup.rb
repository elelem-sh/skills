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

        agent.commands.register("skills", description: "List available skills, or `/skills fetch <origin>` to install from a remote index", completions: completions) do |arg|
          if arg&.start_with?("fetch ")
            fetch(agent, arg.delete_prefix("fetch ").strip)
          elsif arg && !arg.empty?
            skill = catalog.find(arg)
            skill ? agent.output.say(skill.body) : agent.output.say("Unknown skill: #{arg}")
          else
            list = catalog.all.map { |skill| "- **#{skill.name}**: #{truncate(skill.description, SUMMARY_LIMIT)}" }.join("\n")
            agent.output.say(list.empty? ? "No skills found." : list, as: :markdown)
          end
        end
      end

      def fetch(agent, origin)
        if origin.empty?
          agent.output.say("Usage: /skills fetch <origin>")
          return
        end

        names = Fetcher.new.fetch(origin)
        return agent.output.say("No skills installed from #{origin}.") if names.empty?

        @catalog.all(reload: true)
        agent.output.say("Installed: #{names.join(", ")}\nAvailable via /skills and the skill tool now. Restart elelem to refresh the skill tool's description with the new catalog.")
      rescue Fetcher::FetchError => e
        agent.output.say(e.message, as: :error)
      end

      def truncate(text, limit)
        return text if text.length <= limit

        "#{text[0, limit]}..."
      end
    end
  end
end
