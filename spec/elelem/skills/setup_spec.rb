# frozen_string_literal: true

RSpec.describe "elelem-skills setup" do
  let(:fixtures) { File.expand_path("../../fixtures/skills", __dir__) }
  let(:agent) { Elelem::Agent.new(Elelem::StubProvider.new) }

  around do |example|
    original = Elelem::Skills::Catalog::LOAD_PATHS
    Elelem::Skills::Catalog.send(:remove_const, :LOAD_PATHS)
    Elelem::Skills::Catalog.const_set(:LOAD_PATHS, [fixtures].freeze)
    example.run
  ensure
    Elelem::Skills::Catalog.send(:remove_const, :LOAD_PATHS)
    Elelem::Skills::Catalog.const_set(:LOAD_PATHS, original)
  end

  before do
    Elelem::Config.default.instance_variable_get(:@registration).setups.fetch("skills").call(agent)
  end

  describe "skill tool" do
    it "advertises the catalog in its description" do
      tool = agent.toolbox.tool_for("skill")

      expect(tool.description).to include("tdd: Test-driven development")
    end

    it "returns the skill body and dir for a known skill" do
      result = agent.toolbox.run("skill", { "name" => "tdd" })

      expect(result).to be_ok
      expect(result[:name]).to eq("tdd")
      expect(result[:dir]).to eq(File.join(fixtures, "tdd"))
      expect(result[:content]).to eq("# TDD\n\nRed, green, refactor.")
    end

    it "fails for an unknown skill" do
      result = agent.toolbox.run("skill", { "name" => "nope" })

      expect(result).not_to be_ok
      expect(result.error).to eq("unknown skill: nope")
    end
  end

  describe "/skills command" do
    it "lists the catalog" do
      output = instance_double(Elelem::Output)
      agent = Elelem::Agent.new(Elelem::StubProvider.new, output: output)
      Elelem::Config.default.instance_variable_get(:@registration).setups.fetch("skills").call(agent)

      expect(output).to receive(:say).with("tdd: Test-driven development. Use when the user wants tests written first.")

      agent.commands.run("skills", nil)
    end

    it "shows a single skill's body" do
      output = instance_double(Elelem::Output)
      agent = Elelem::Agent.new(Elelem::StubProvider.new, output: output)
      Elelem::Config.default.instance_variable_get(:@registration).setups.fetch("skills").call(agent)

      expect(output).to receive(:say).with("# TDD\n\nRed, green, refactor.")

      agent.commands.run("skills", "tdd")
    end
  end
end
