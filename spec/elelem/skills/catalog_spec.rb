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

  describe "#find" do
    it "returns nil for an unknown skill" do
      catalog = described_class.new(load_paths: [fixtures])

      expect(catalog.find("nope")).to be_nil
    end
  end
end
