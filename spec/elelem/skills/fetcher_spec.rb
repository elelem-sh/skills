# frozen_string_literal: true

RSpec.describe Elelem::Skills::Fetcher do
  let(:install_dir) { Dir.mktmpdir }
  let(:http) { class_double(Net::HTTP) }
  let(:lockfile) { Elelem::Skills::Lockfile.new(File.join(install_dir, ".skill-lock.json")) }
  let(:fetcher) { described_class.new(install_dir: install_dir, http: http) }

  after { FileUtils.rm_rf(install_dir) }

  def ok(body)
    res = Net::HTTPOK.new("1.1", "200", "OK")
    res.instance_variable_set(:@read, true)
    res.body = body
    res
  end

  def moved(location)
    res = Net::HTTPMovedPermanently.new("1.1", "301", "Moved Permanently")
    res.instance_variable_set(:@read, true)
    res["location"] = location
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

  describe "#fetch with redirects" do
    it "follows them, and resolves skill URLs against the final index URL" do
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(moved("https://www.example.com/.well-known/agent-skills/index.json"))
      allow(http).to receive(:get_response)
        .with(URI("https://www.example.com/.well-known/agent-skills/index.json")).and_return(ok(index))
      allow(http).to receive(:get_response)
        .with(URI("https://www.example.com/.well-known/agent-skills/example/SKILL.md")).and_return(ok(skill_body))

      expect(fetcher.fetch("example.com")).to eq(["example"])
    end

    it "refuses a redirect from https to http" do
      allow(http).to receive(:get_response).and_return(moved("http://example.com/index.json"))

      expect { fetcher.fetch("example.com") }.to raise_error(described_class::FetchError, /refusing redirect/)
    end

    it "stops after too many redirects" do
      allow(http).to receive(:get_response).and_return(moved("/again"))

      expect { fetcher.fetch("example.com") }.to raise_error(described_class::FetchError, /too many redirects/)
    end
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
      expect(File.read(File.join(install_dir, "example.com", "example", "SKILL.md"))).to eq(skill_body)
    end

    it "records the install in the lockfile, keyed by host/name" do
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(ok(index))
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/example/SKILL.md"))
        .and_return(ok(skill_body))

      fetcher.fetch("example.com")
      entry = lockfile.read.dig("skills", "example.com/example")

      expect(entry["host"]).to eq("example.com")
      expect(entry["name"]).to eq("example")
      expect(entry["url"]).to eq("https://example.com/.well-known/agent-skills/example/SKILL.md")
      expect(entry["digest"]).to eq(digest)
      expect(entry["installedAt"]).not_to be_nil
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

      expect do
        fetcher.fetch("example.com")
      end.to raise_error(Elelem::Skills::Fetcher::FetchError, /unrecognized index schema/)
    end

    it "raises when the schema field is absent (treated as incompatible v0.1.0)" do
      no_schema = JSON.parse(index).tap { |h| h.delete("$schema") }.to_json
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(ok(no_schema))

      expect do
        fetcher.fetch("example.com")
      end.to raise_error(Elelem::Skills::Fetcher::FetchError, /unrecognized index schema/)
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

    it "partitions by host so two origins publishing the same skill name don't clobber each other" do
      other_body = "---\nname: example\ndescription: A different example skill, from another host.\n---\nOther body.\n"
      other_digest = "sha256:#{Digest::SHA256.hexdigest(other_body)}"
      other_index = {
        "$schema" => Elelem::Skills::Fetcher::SCHEMA,
        "skills" => [
          { "name" => "example", "type" => "skill-md", "description" => "A different example skill.",
            "url" => "/.well-known/agent-skills/example/SKILL.md", "digest" => other_digest }
        ]
      }.to_json

      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/index.json"))
        .and_return(ok(index))
      allow(http).to receive(:get_response)
        .with(URI("https://example.com/.well-known/agent-skills/example/SKILL.md"))
        .and_return(ok(skill_body))
      allow(http).to receive(:get_response)
        .with(URI("https://other.example/.well-known/agent-skills/index.json"))
        .and_return(ok(other_index))
      allow(http).to receive(:get_response)
        .with(URI("https://other.example/.well-known/agent-skills/example/SKILL.md"))
        .and_return(ok(other_body))

      fetcher.fetch("example.com")
      fetcher.fetch("other.example")

      expect(File.read(File.join(install_dir, "example.com", "example", "SKILL.md"))).to eq(skill_body)
      expect(File.read(File.join(install_dir, "other.example", "example", "SKILL.md"))).to eq(other_body)
    end

    it "lowercases the host when using it as a directory name" do
      index_url = URI("https://Example.COM/.well-known/agent-skills/index.json")
      allow(http).to receive(:get_response).with(index_url).and_return(ok(index))
      allow(http).to receive(:get_response)
        .with(URI("https://Example.COM/.well-known/agent-skills/example/SKILL.md"))
        .and_return(ok(skill_body))

      fetcher.fetch("Example.COM")

      expect(File.directory?(File.join(install_dir, "example.com"))).to be(true)
    end
  end
end
