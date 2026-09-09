# frozen_string_literal: true

require "elelem"
require "yaml"

require_relative "skills/version"
require_relative "skills/skill"
require_relative "skills/skill_file"
require_relative "skills/catalog"
require_relative "skills/lockfile"
require_relative "skills/fetcher"
require_relative "skills/setup"
require_relative "skills/cli"

Elelem.configure do |config|
  config.setup(:skills) do |agent|
    Elelem::Skills::Setup.call(agent)
  end
end
