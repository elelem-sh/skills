# frozen_string_literal: true

Elelem::Plugins.register(:skill) do |agent|
  agent.commands.register("skill", description: "Invoke a skill (not yet implemented)") do |_args|
    agent.terminal.say NotImplementedError.new("skills are not implemented yet").message
  end
end
