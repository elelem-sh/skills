# frozen_string_literal: true

Elelem.configure do |config|
  config.setup(:skills) do |agent|
    catalog = Elelem::Skills::Catalog.new
    next if catalog.all.empty?

    index = -> do
      catalog.all.map { |skill| Elelem::Skills::Skill.truncate(skill.summary) }.join("\n")
    end

    agent.toolbox.add("skill",
      description: "Load a skill's instructions by name. Available skills:\n#{index.call}",
      params: { name: { type: "string", description: "the skill name" } },
      required: ["name"]
    ) do |a|
      skill = catalog.find(a["name"])
      next { error: "unknown skill: #{a["name"]}" } unless skill

      { name: skill.name, dir: skill.dir, content: skill.body }
    end

    completions = -> { catalog.all.map(&:name) }

    agent.commands.register("skills", description: "List available skills", completions: completions) do |arg|
      if arg && !arg.empty?
        skill = catalog.find(arg)
        unless skill
          agent.output.say "Unknown skill: #{arg}"
          next
        end

        agent.output.say skill.body
      else
        list = catalog.all
        if list.empty?
          agent.output.say "No skills installed."
        else
          agent.output.say list.map(&:summary).join("\n")
        end
      end
    end
  end
end
