# frozen_string_literal: true

require "elelem"

require_relative "skills/version"
require_relative "skills/mode"

Elelem::SystemPrompt.add_load_path(File.expand_path("skills/prompts", __dir__))
