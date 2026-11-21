# frozen_string_literal: true

require_relative "lib/elelem/skills/version"

Gem::Specification.new do |spec|
  spec.name = "elelem-skills"
  spec.version = Elelem::Skills::VERSION
  spec.authors = ["mo khan"]
  spec.email = ["mo@mokhan.ca"]

  spec.summary = "Skill loader for elelem."
  spec.description = "Discovers and loads .agents/skills/*/SKILL.md skills (per the agent skills standard) " \
                     "as an elelem tool and /skills command."
  spec.homepage = "https://elelem.sh"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/elelem-sh/skills"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["LICENSE.txt", "lib/**/*.rb", "exe/*"]
  spec.require_paths = ["lib"]
  spec.bindir = "exe"
  spec.executables = ["elelem-skills"]

  spec.add_dependency "elelem", ">= 0.13.1", "< 1"
  spec.add_dependency "json", ">= 2.18"
  spec.add_dependency "net-http", "~> 0.9"
  spec.add_dependency "yaml", "~> 0.4"
end
