# frozen_string_literal: true

module Elelem
  module Skills
    class CLI
      COMMANDS = %w[fetch list help].freeze

      def initialize(args)
        @args = args
      end

      def run
        command = @args.shift || "help"
        command = "help" if %w[-h --help].include?(command)
        abort "Unknown command: #{command}\n\n#{usage}" unless COMMANDS.include?(command)
        send(command)
      end

      private

      def fetch
        origin = @args.shift
        abort "Usage: elelem-skills fetch <origin>" unless origin

        names = Fetcher.new.fetch(origin)
        return puts "No skills installed from #{origin}." if names.empty?

        puts "Installed: #{names.join(", ")}"
      rescue Fetcher::FetchError => e
        abort "elelem-skills: #{e.message}"
      end

      def list
        catalog = Catalog.new
        return puts "No skills found." if catalog.all.empty?

        catalog.all.each { |skill| puts skill.summary }
      end

      def help
        puts usage
      end

      def usage
        <<~USAGE
          Usage: elelem-skills <command> [args]

          Commands:
            fetch <origin>    Install skills from <origin>/.well-known/agent-skills/index.json
            list              List all discovered skills
            help              Show this help
        USAGE
      end
    end
  end
end
