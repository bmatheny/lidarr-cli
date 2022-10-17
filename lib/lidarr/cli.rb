# frozen_string_literal: true

require_relative "../lidarr"
require_relative "config"
require "httparty"
require "pp"
require "thor"
require "thor/group"

# Thor docs: https://github.com/rails/thor/wiki

class SubCommandBase < Thor
  class << self
    def banner(command, namespace = nil, subcommand = false)
      "#{basename} #{subcommand_prefix} #{command.usage}"
    end

    def subcommand_prefix
      name.gsub(%r{.*::}, "").gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
    end
  end
end

module HTTPHelpers
  def self.party_opts opts
    headers = opts.headers
    headers["x-api-key"] = opts.api_key.get
    {
      headers: headers,
      verify: false,
      verbose: opts.verbose.get_or_else(false)
    }
  end
end

module Lidarr
  class Wanted < SubCommandBase
    URI = "/api/v1/wanted"

    desc "missing", "Get missing albums"
    def missing
      opts = HTTPHelpers.party_opts(CLI.get_options(options))
      response = HTTParty.get("#{opts.url.get}#{URI}/missing", opts)
      pp response
    end

    desc "add <name> <url>", "Adds a remote named <name> for the repo at <url>"
    long_desc <<-LONGDESC
      Foo bar.

      And more here.
        -stuff
        -thing

      Blah
    LONGDESC
    option :t, banner: "<branch>"
    option :m, banner: "<master>"
    options f: :boolean, tags: :boolean, mirror: :string
    def add(name, url)
    end

    desc "rename <old> <new>", "Rename the remote named <old> to <new>"
    def rename(old, new)
    end
  end # end class Wanted

  class CLI < Thor
    class_option :api_key, type: :string, aliases: "-K",
      banner: "API_KEY",
      desc: "The API key to use with each request"
    class_option :header, type: :string, aliases: "-H", repeatable: true,
      desc: "Any additional header options to be passed"
    class_option :url, type: :string, aliases: "-U",
      desc: "URL to call, should include scheme, port, and any subfolder"
    class_option :verbose, type: :boolean, aliases: "-v", repeatable: true,
      desc: "Increase the verbosity of the program"

    desc "version", "prints lidarr CLI version"
    def version
      puts Lidarr::VERSION
    end

    desc "wanted SUBCOMMAND [OPTIONS] [ARGS]", "work with missing or cutoff albums"
    subcommand "wanted", Wanted

    no_commands do
      class << self
        def get_options options
          puts "Get_options called"
          opts = Lidarr::Config.options_from_configs
          if options.key?("api_key")
            opts.api_key = options.api_key
          end
          if options.key?("header")
            options.header.each { |hdr| opts.header_set hdr }
          end
          if options.key?("url")
            opts.url = options.url
          end
          if options.key?("verbose")
            options.verbose.each { |v| opts.verbose = v }
          end
          opts
        end # def get_options
      end # class << self
    end # no_commands
  end # end class CLI
end # end module Lidarr
