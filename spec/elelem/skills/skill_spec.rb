# frozen_string_literal: true

RSpec.describe Elelem::Skills::Skill do
  let(:fixtures) { File.expand_path("../../fixtures/skills", __dir__) }

  describe ".load" do
    it "parses frontmatter and body" do
      skill = described_class.load(File.join(fixtures, "tdd", "SKILL.md"))

      expect(skill.name).to eq("tdd")
      expect(skill.description).to eq("Test-driven development. Use when the user wants tests written first.")
      expect(skill.dir).to eq(File.join(fixtures, "tdd"))
      expect(skill.body).to eq("# TDD\n\nRed, green, refactor.")
    end

    it "returns nil when description is missing" do
      skill = described_class.load(File.join(fixtures, "no-description", "SKILL.md"))

      expect(skill).to be_nil
    end

    it "returns nil when there is no frontmatter" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "SKILL.md")
        File.write(path, "just a body, no frontmatter\n")

        expect(described_class.load(path)).to be_nil
      end
    end
  end

  describe "#summary" do
    it "combines name and description" do
      skill = described_class.new(name: "tdd", description: "desc", dir: ".", path: "SKILL.md", body: "")

      expect(skill.summary).to eq("tdd: desc")
    end
  end

  describe ".truncate" do
    it "leaves short text untouched" do
      expect(described_class.truncate("short")).to eq("short")
    end

    it "caps long text and marks it as truncated" do
      text = "a" * 500
      result = described_class.truncate(text, limit: 400)

      expect(result.length).to eq(403)
      expect(result).to end_with("...")
    end
  end
end
