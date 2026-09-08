# frozen_string_literal: true

RSpec.describe Elelem::Skills::Fetcher do
  let(:install_dir) { Dir.mktmpdir }
  let(:http) { class_double(Net::HTTP) }
  let(:fetcher) { described_class.new(install_dir: install_dir, http: http) }

  after { FileUtils.rm_rf(install_dir) }

  def ok(body)
    res = Net::HTTPOK.new("1.1", "200", "OK")
    res.instance_variable_set(:@read, true)
    res.body = body
    res
  end

  def not_found
    res = Net::HTTPNotFound.new("1.1", "404", "Not Found")
    res.instance_variable_set(:@read, true)
    res.body = ""
    res
  end

  let(:skill_body) { "---\nname: example\ndescription: An example skill.\n---\nBody.\n" }
  let(:digest) { "sha256:#{Digest::SHA256.hexdigest(skill_body)}" }

  let(:index) do
    {
      "$schema" => Elelem::Skills::Fetcher::SCHEMA,
      "skills" => [
        { "name" => "example", "type" => "skill-md", "description" => "An example skill.",
          "url" => "/.well-known/agent-skills/example/SKILL.md", "digest" => digest }
      ]
    }.to_json
  end

  describe "#fetch" do
    it "installs a skill-md entry whose digest matches" do
      expect(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(ok(index))
      expect(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/example/SKILL.md"))
        .and_return(ok(skill_body))

      names = fetcher.fetch("example.com")

      expect(names).to eq(["example"])
      expect(File.read(File.join(install_dir, "example", "SKILL.md"))).to eq(skill_body)
    end

    it "adds https:// when the origin has no scheme" do
      expect(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(ok(index))
      allow(http).to receive(:get_response).with(URI("https://example.com/.well-known/agent-skills/example/SKILL.md")).and_return(ok(skill_body))

      fetcher.fetch("example.com")
    end

    it "raises when the digest does not match" do
      tampered = index.sub(digest, "sha256:#{"0" * 64}")
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(ok(tampered))
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/example/SKILL.md"))
        .and_return(ok(skill_body))

      expect { fetcher.fetch("example.com") }.to raise_error(Elelem::Skills::Fetcher::FetchError, /digest mismatch/)
    end

    it "raises on an unrecognized schema" do
      bad = index.sub(Elelem::Skills::Fetcher::SCHEMA, "https://schemas.agentskills.io/discovery/9.9.9/schema.json")
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(ok(bad))

      expect { fetcher.fetch("example.com") }.to raise_error(Elelem::Skills::Fetcher::FetchError, /unrecognized index schema/)
    end

    it "raises when the schema field is absent (treated as incompatible v0.1.0)" do
      no_schema = JSON.parse(index).tap { |h| h.delete("$schema") }.to_json
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(ok(no_schema))

      expect { fetcher.fetch("example.com") }.to raise_error(Elelem::Skills::Fetcher::FetchError, /unrecognized index schema/)
    end

    it "skips archive entries and warns, without raising" do
      archive_index = {
        "$schema" => Elelem::Skills::Fetcher::SCHEMA,
        "skills" => [
          { "name" => "bundled", "type" => "archive", "description" => "Has resources.",
            "url" => "/.well-known/agent-skills/bundled.tar.gz", "digest" => "sha256:#{"0" * 64}" }
        ]
      }.to_json
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(ok(archive_index))
      expect(Elelem.logger).to receive(:warn).with(/unsupported type "archive"/)

      expect(fetcher.fetch("example.com")).to eq([])
    end

    it "raises when the index request fails" do
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(not_found)

      expect { fetcher.fetch("example.com") }.to raise_error(Elelem::Skills::Fetcher::FetchError, /404/)
    end
  end
end
