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
  spec.homepage = "https://src.mokhan.ca/elelem/skills"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || f.start_with?(*%w[bin/ Gemfile .gitignore])
    end
  end
  spec.require_paths = ["lib"]
  spec.bindir = "exe"
  spec.executables = ["elelem-skills"]

  spec.add_dependency "elelem", ">= 0.12", "< 1"
  spec.add_dependency "json", "~> 3.0"
  spec.add_dependency "net-http", "~> 0.9"
  spec.add_dependency "yaml", "~> 0.4"
end
