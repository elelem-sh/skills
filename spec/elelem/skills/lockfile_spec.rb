# frozen_string_literal: true

RSpec.describe Elelem::Skills::Lockfile do
  let(:dir) { Dir.mktmpdir }
  let(:path) { File.join(dir, ".skill-lock.json") }
  let(:lockfile) { described_class.new(path) }

  after { FileUtils.rm_rf(dir) }

  describe "#read" do
    it "returns an empty skills map when the file does not exist" do
      expect(lockfile.read).to eq({ "version" => 1, "skills" => {} })
    end
  end

  describe "#record" do
    it "writes a new entry keyed by host/name" do
      lockfile.record(host: "example.com", name: "example", url: "https://example.com/example/SKILL.md",
                      digest: "sha256:abc")

      entry = lockfile.read.dig("skills", "example.com/example")
      expect(entry["host"]).to eq("example.com")
      expect(entry["name"]).to eq("example")
      expect(entry["url"]).to eq("https://example.com/example/SKILL.md")
      expect(entry["digest"]).to eq("sha256:abc")
      expect(entry["installedAt"]).to eq(entry["updatedAt"])
    end

    it "keeps the original installedAt but bumps updatedAt on re-install" do
      lockfile.record(host: "example.com", name: "example", url: "https://example.com/example/SKILL.md",
                      digest: "sha256:abc")
      first_installed_at = lockfile.read.dig("skills", "example.com/example", "installedAt")

      lockfile.record(host: "example.com", name: "example", url: "https://example.com/example/SKILL.md",
                      digest: "sha256:def")
      entry = lockfile.read.dig("skills", "example.com/example")

      expect(entry["installedAt"]).to eq(first_installed_at)
      expect(entry["digest"]).to eq("sha256:def")
    end

    it "does not clobber an entry for the same skill name from a different host" do
      lockfile.record(host: "example.com", name: "example", url: "https://example.com/example/SKILL.md",
                      digest: "sha256:abc")
      lockfile.record(host: "other.example", name: "example", url: "https://other.example/example/SKILL.md",
                      digest: "sha256:def")

      expect(lockfile.read["skills"].keys).to contain_exactly("example.com/example", "other.example/example")
    end
  end
end
