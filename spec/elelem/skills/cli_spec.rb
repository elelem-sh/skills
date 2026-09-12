# frozen_string_literal: true

RSpec.describe Elelem::Skills::CLI do
  def capture_stdout
    original = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original
  end

  describe "#run" do
    it "fetches skills from an origin and prints the installed names" do
      fetcher = instance_double(Elelem::Skills::Fetcher, fetch: ["example"])
      allow(Elelem::Skills::Fetcher).to receive(:new).and_return(fetcher)

      output = capture_stdout { described_class.new(["fetch", "example.com"]).run }

      expect(fetcher).to have_received(:fetch).with("example.com")
      expect(output).to include("Installed: example")
    end

    it "reports when nothing was installed" do
      fetcher = instance_double(Elelem::Skills::Fetcher, fetch: [])
      allow(Elelem::Skills::Fetcher).to receive(:new).and_return(fetcher)

      output = capture_stdout { described_class.new(["fetch", "example.com"]).run }

      expect(output).to include("No skills installed from example.com")
    end

    it "aborts with the fetch error message on failure" do
      fetcher = instance_double(Elelem::Skills::Fetcher)
      allow(fetcher).to receive(:fetch).and_raise(Elelem::Skills::Fetcher::FetchError, "boom")
      allow(Elelem::Skills::Fetcher).to receive(:new).and_return(fetcher)

      expect { described_class.new(["fetch", "example.com"]).run }.to raise_error(SystemExit)
    end

    it "requires an origin for fetch" do
      expect { described_class.new(["fetch"]).run }.to raise_error(SystemExit)
    end

    it "lists discovered skills" do
      fixtures = File.expand_path("../../fixtures/skills", __dir__)
      catalog = instance_double(Elelem::Skills::Catalog,
                                all: [Elelem::Skills::Skill.new("tdd", "Test-driven development.", fixtures, "body")])
      allow(Elelem::Skills::Catalog).to receive(:new).and_return(catalog)

      output = capture_stdout { described_class.new(["list"]).run }

      expect(output).to include("tdd: Test-driven development.")
    end

    it "prints usage for an unknown command" do
      expect { described_class.new(["bogus"]).run }.to raise_error(SystemExit)
    end

    it "prints usage with no args" do
      output = capture_stdout { described_class.new([]).run }

      expect(output).to include("Usage: elelem-skills")
    end
  end
end
