# frozen_string_literal: true

require_relative "../lidarr"
require_relative "config"
require "httparty"
require "pp"
require "thor"
require "thor/group"

# Thor docs: https://github.com/rails/thor/wiki
class BasicSubcommand < Thor
  class << self
    def banner(command, namespace = nil, subcommand = false)
      "#{basename} #{subcommand_prefix} #{command.usage}"
    end

    def subcommand_prefix
      name.gsub(%r{.*::}, "").gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
    end
  end
end

class PagedSubcommand < BasicSubcommand
  # Pagination related options applicable to many endpoints
  class_option :page, type: :numeric, desc: "Page number (1 indexed)"
  class_option :page_size, type: :numeric, desc: "Number of results to return"
  class_option :sort_key, type: :string, desc: "Key for sorting, e.g. releaseDate or artistName"
  class_option :sort_direction, type: :string, enum: %w[default ascending descending], desc: "Sort order"
end

module CLIHelpers
  extend self

  def get_options options
    opts = Lidarr::Config.options_from_configs
    opts.merge(Lidarr::Opt.thor_to_options(options))
  end

  def get_paging_options options
    Lidarr::API::PagingRequest.new(
      page: options.fetch("page", nil),
      page_size: options.fetch("page_size", nil),
      sort_key: options.fetch("sort_key", nil),
      sort_direction: options.fetch("sort_direction", nil),
      filters: options.fetch("filters", nil)
    )
  end

  def print_results options, results
    if options.format == "plain"
      shell = Thor::Shell::Basic.new
      if results.is_a?(Lidarr::API::PagingResource)
        rows = []
        rows << ["ID", "Artist Name", "Album Title", "Monitored", "Album Type", "Release Date"]
        results.records.each do |res|
          # TODO fixme looks like Album Type is always Album?
          rows << [res.id, res.artist.artistName, res.title, res.monitored, res.albumType, res.releaseDate]
        end
        shell.print_table(rows)
        puts("")
        puts("Page: #{results.page}, Total Records: #{results.total_records}, Filters: #{results.filters.inspect}, Sort Key: #{results.sort_key}")
      else
        unless results.is_a?(Array)
          results = [results]
        end
        results.each do |result|
          puts("          ID: #{result.id}")
          puts(" Artist Name: #{result.artist.artistName}")
          puts(" Album Title: #{result.title}")
          puts("   Monitored: #{result.monitored}")
          puts("  Album Type: #{result.albumType}")
          puts("Release Date: #{result.releaseDate}")
          puts("")
        end
      end
    else
      puts "Unsupported format #{options.format}"
      exit 1
    end
  end
end

module Lidarr
  class Album < BasicSubcommand
    desc "monitor IDs", "Set the monitor bit for an album with id ID"
    def monitor(*ids)
      app_options = CLIHelpers.get_options(options)
      results = Lidarr::API::Album.new(app_options).monitor(ids)
      CLIHelpers.print_results(options, results)
    end

    desc "unmonitor IDs", "Unset the monitor bit for an album with id ID"
    def unmonitor(*ids)
      app_options = CLIHelpers.get_options(options)
      results = Lidarr::API::Album.new(app_options).unmonitor(ids)
      CLIHelpers.print_results(options, results)
    end
  end

  class Wanted < PagedSubcommand
    desc "missing [ID]", "Get missing albums"
    long_desc <<-LONGDESC
      Get missing albums.

      If you provide an ID, it is expected that you are querying about a specific
      album. The ID is optional.

      If you pass --include-artist, each row will have additional detail.

      Takes standard pagination options as well.
    LONGDESC
    option :include_artist, type: :boolean, default: false,
      desc: "Include artist info"
    def missing(id = nil)
      app_options = CLIHelpers.get_options(options)
      paging_opts = CLIHelpers.get_paging_options(options)
      results = Lidarr::API::Wanted.new(app_options).missing(id: id, include_artist: options.include_artist, paging_resource: paging_opts)
      CLIHelpers.print_results(options, results)
    end
  end # end class Wanted

  class CLI < Thor
    class_option :api_key, type: :string, aliases: "-K",
      banner: "API_KEY",
      desc: "The API key to use with each request"
    class_option :header, type: :string, aliases: "-H", repeatable: true,
      desc: "Any additional header options to be passed"
    class_option :format, type: :string, aliases: "-F",
      enum: %w[plain csv json yml], default: "plain",
      desc: "Output format to use, defaults to 'plain'"
    class_option :secure, type: :boolean, aliases: "-S",
      desc: "Whether we should connect securely to https endpoints or not"
    class_option :url, type: :string, aliases: "-U",
      desc: "URL to call, should include scheme, port, and any subfolder"
    class_option :verbose, type: :boolean, aliases: "-v", repeatable: true,
      desc: "Increase the verbosity of the program"

    desc "version", "prints lidarr CLI version"
    def version
      puts Lidarr::VERSION
    end

    desc "album SUBCOMMAND [OPTIONS] [ARGS]", "work with albums"
    subcommand "album", Album

    desc "wanted SUBCOMMAND [OPTIONS] [ARGS]", "work with missing or cutoff albums"
    subcommand "wanted", Wanted
  end # end class CLI
end # end module Lidarr
