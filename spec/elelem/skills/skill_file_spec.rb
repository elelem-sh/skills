# frozen_string_literal: true

RSpec.describe Elelem::Skills::SkillFile do
  describe ".parse" do
    it "parses frontmatter and body into a Skill" do
      text = <<~SKILL
        ---
        name: tdd
        description: Test-driven development.
        ---

        # TDD

        Red, green, refactor.
      SKILL

      skill = described_class.parse(text, path: "/skills/tdd/SKILL.md")

      expect(skill.name).to eq("tdd")
      expect(skill.description).to eq("Test-driven development.")
      expect(skill.dir).to eq("/skills/tdd")
      expect(skill.body).to eq("# TDD\n\nRed, green, refactor.")
    end

    it "returns nil when description is missing" do
      text = <<~SKILL
        ---
        name: tdd
        ---
        body
      SKILL

      expect(described_class.parse(text, path: "SKILL.md")).to be_nil
    end

    it "returns nil when there is no frontmatter" do
      expect(described_class.parse("just a body, no frontmatter\n", path: "SKILL.md")).to be_nil
    end
  end

  describe ".load" do
    it "reads the file and parses it" do
      fixtures = File.expand_path("../../fixtures/skills", __dir__)

      skill = described_class.load(File.join(fixtures, "tdd", "SKILL.md"))

      expect(skill.name).to eq("tdd")
      expect(skill.dir).to eq(File.join(fixtures, "tdd"))
    end

    it "returns nil for a skill with no description" do
      fixtures = File.expand_path("../../fixtures/skills", __dir__)

      skill = described_class.load(File.join(fixtures, "no-description", "SKILL.md"))

      expect(skill).to be_nil
    end
  end

  it "reads a file with Windows line endings and a byte order mark" do
    text = "\uFEFF---\r\nname: win\r\ndescription: Saved on Windows.\r\n---\r\nBody.\r\n"
    skill = described_class.parse(text, path: "/skills/win/SKILL.md")

    expect([skill.name, skill.description, skill.body]).to eq(["win", "Saved on Windows.", "Body."])
  end

  it "loads a UTF-8 file with a byte order mark under a non-UTF-8 locale" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "SKILL.md")
      File.binwrite(path, "\xEF\xBB\xBF---\r\nname: caf\u00e9\r\ndescription: Accents.\r\n---\r\nBody.\r\n")
      original = Encoding.default_external
      Encoding.default_external = Encoding::US_ASCII

      expect(described_class.load(path).name).to eq("caf\u00e9")
    ensure
      Encoding.default_external = original
    end
  end
end
