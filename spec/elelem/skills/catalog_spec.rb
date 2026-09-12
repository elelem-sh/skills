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

  describe "REMOTE_SKILLS" do
    it "discovers skills fetched into <remote_skills>/<host>/<name>/SKILL.md" do
      Dir.mktmpdir do |remote_root|
        skill_dir = File.join(remote_root, "example.com", "wrangler")
        FileUtils.mkdir_p(skill_dir)
        File.write(File.join(skill_dir, "SKILL.md"), <<~SKILL)
          ---
          name: wrangler
          description: fetched from example.com
          ---
          body
        SKILL

        catalog = described_class.new(load_paths: [], remote_skills: remote_root)

        expect(catalog.find("wrangler")&.description).to eq("fetched from example.com")
      end
    end

    it "does not use a recursive glob that would pick up a nested SKILL.md" do
      Dir.mktmpdir do |remote_root|
        nested = File.join(remote_root, "example.com", "wrangler", "resources", "nested")
        FileUtils.mkdir_p(nested)
        File.write(File.join(nested, "SKILL.md"), <<~SKILL)
          ---
          name: nested-imposter
          description: should not be discovered
          ---
          body
        SKILL

        catalog = described_class.new(load_paths: [], remote_skills: remote_root)

        expect(catalog.find("nested-imposter")).to be_nil
      end
    end

    it "lets a user-level skill of the same name shadow a remote-fetched one" do
      Dir.mktmpdir do |remote_root|
        skill_dir = File.join(remote_root, "example.com", "tdd")
        FileUtils.mkdir_p(skill_dir)
        File.write(File.join(skill_dir, "SKILL.md"), <<~SKILL)
          ---
          name: tdd
          description: remote version
          ---
          body
        SKILL

        catalog = described_class.new(load_paths: [fixtures], remote_skills: remote_root)

        expect(catalog.find("tdd").description)
          .to eq("Test-driven development. Use when the user wants tests written first.")
      end
    end

    it "is not scanned when remote_skills is nil" do
      catalog = described_class.new(load_paths: [], remote_skills: nil)

      expect { catalog.all }.not_to raise_error
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
