# frozen_string_literal: true

RSpec.describe Elelem::Skills::Catalog do
  let(:fixtures) { File.expand_path("../../fixtures/skills", __dir__) }

  describe "#all" do
    it "discovers skills with valid frontmatter and skips invalid ones" do
      catalog = described_class.new(load_paths: [fixtures])

      expect(catalog.all.map(&:name)).to eq(["tdd"])
    end

    it "lets later load paths shadow earlier ones by name" do
      Dir.mktmpdir do |override_root|
        override_dir = File.join(override_root, "tdd")
        FileUtils.mkdir_p(override_dir)
        File.write(File.join(override_dir, "SKILL.md"), <<~SKILL)
          ---
          name: tdd
          description: overridden
          ---
          overridden body
        SKILL

        catalog = described_class.new(load_paths: [fixtures, override_root])

        expect(catalog.find("tdd").description).to eq("overridden")
      end
    end

    it "returns an empty list when no load paths exist" do
      catalog = described_class.new(load_paths: ["/nonexistent/path"])

      expect(catalog.all).to eq([])
    end
  end

  describe "GEM_SKILLS" do
    it "bundles the scrum skill with the gem" do
      catalog = described_class.new

      expect(catalog.all.map(&:name)).to include("scrum")
    end

    it "does not treat the scrum skill's phase files as separate skills" do
      catalog = described_class.new

      expect(catalog.all.map(&:name)).not_to include("plan", "design", "build", "review", "verify")
    end
  end

  describe "#find" do
    it "returns nil for an unknown skill" do
      catalog = described_class.new(load_paths: [fixtures])

      expect(catalog.find("nope")).to be_nil
    end
  end

  describe "#index" do
    it "joins summaries without truncating by default" do
      catalog = described_class.new(load_paths: [fixtures])

      expect(catalog.index).to eq("tdd: Test-driven development. Use when the user wants tests written first.")
    end

    it "truncates summaries when a limit is given" do
      catalog = described_class.new(load_paths: [fixtures])

      expect(catalog.index(limit: 10)).to eq("tdd: Test-...")
    end
  end
end
