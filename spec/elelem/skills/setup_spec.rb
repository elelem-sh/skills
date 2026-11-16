# frozen_string_literal: true

RSpec.describe "elelem-skills setup" do
  let(:fixtures) { File.expand_path("../../fixtures/skills", __dir__) }
  let(:agent) { Elelem::Session.new(Elelem::Agent.new(Object.new)) }

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
    Elelem::Skills::Setup.call(agent)
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
      expect(result[:error]).to eq("unknown skill: nope")
    end
  end

  describe "/skills command" do
    it "lists the catalog" do
      output = instance_double(Elelem::Output)
      agent = Elelem::Session.new(Elelem::Agent.new(Object.new, output: output))
      Elelem::Skills::Setup.call(agent)

      expect(output).to receive(:say).with(
        "- **tdd**: Test-driven development. Use when the user wants tests written first.", as: :markdown
      )

      agent.commands.run("skills", nil)
    end

    it "shows a single skill's body" do
      output = instance_double(Elelem::Output)
      agent = Elelem::Session.new(Elelem::Agent.new(Object.new, output: output))
      Elelem::Skills::Setup.call(agent)

      expect(output).to receive(:say).with("# TDD\n\nRed, green, refactor.")

      agent.commands.run("skills", "tdd")
    end
  end

  describe "with an empty catalog" do
    around do |example|
      original = Elelem::Skills::Catalog::LOAD_PATHS
      Elelem::Skills::Catalog.send(:remove_const, :LOAD_PATHS)
      Elelem::Skills::Catalog.const_set(:LOAD_PATHS, [].freeze)
      example.run
    ensure
      Elelem::Skills::Catalog.send(:remove_const, :LOAD_PATHS)
      Elelem::Skills::Catalog.const_set(:LOAD_PATHS, original)
    end

    it "still registers the skill tool and /skills command so remote skills can be fetched" do
      agent = Elelem::Session.new(Elelem::Agent.new(Object.new))
      Elelem::Config.apply(agent)

      expect(agent.toolbox.tool_for("skill")).not_to be_nil
      expect(agent.commands.names).to include("/skills")
    end

    it "sees a skill fetched via /skills fetch without re-running setup" do
      remote_root = Dir.mktmpdir
      begin
        original_remote = Elelem::Skills::Catalog::REMOTE_SKILLS
        Elelem::Skills::Catalog.send(:remove_const, :REMOTE_SKILLS)
        Elelem::Skills::Catalog.const_set(:REMOTE_SKILLS, remote_root)

        output = instance_double(Elelem::Output)
        allow(output).to receive(:say)
        agent = Elelem::Session.new(Elelem::Agent.new(Object.new, output: output))
        Elelem::Skills::Setup.call(agent)

        fetcher = instance_double(Elelem::Skills::Fetcher, fetch: ["wrangler"], changed: [])
        allow(Elelem::Skills::Fetcher).to receive(:new).and_return(fetcher)
        skill_dir = File.join(remote_root, "example.com", "wrangler")
        FileUtils.mkdir_p(skill_dir)
        File.write(File.join(skill_dir, "SKILL.md"), <<~SKILL)
          ---
          name: wrangler
          description: fetched from example.com
          ---
          body
        SKILL

        agent.commands.run("skills", "fetch example.com")

        expect(output).to have_received(:say).with(/Installed: wrangler/)
        result = agent.toolbox.run("skill", { "name" => "wrangler" })
        expect(result).to be_ok
      ensure
        FileUtils.rm_rf(remote_root)
        Elelem::Skills::Catalog.send(:remove_const, :REMOTE_SKILLS)
        Elelem::Skills::Catalog.const_set(:REMOTE_SKILLS, original_remote)
      end
    end
  end
end
