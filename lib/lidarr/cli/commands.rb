# frozen_string_literal: true

require_relative "option_helpers"
require_relative "output"
require_relative "../../lidarr"

require "pp"
require "thor"
require "thor/group"

# Thor docs: https://github.com/rails/thor/wiki

module Lidarr
  module CLI
    class BasicSubcommand < Thor
      no_commands do
        def logger
          Lidarr::Logging.get
        end
      end

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

    class Album < BasicSubcommand
      desc "monitor IDs", "Set the monitor bit for an album with id ID"
      def monitor(*ids)
        app_options = OptionHelpers.get_options(options)
        results = Lidarr::API::Album.new(app_options).monitor(ids)
        Output.print_results(options.format, results)
      end

      desc "unmonitor IDs", "Unset the monitor bit for an album with id ID"
      def unmonitor(*ids)
        app_options = OptionHelpers.get_options(options)
        results = Lidarr::API::Album.new(app_options).unmonitor(ids)
        Output.print_results(options.format, results)
      end
    end

    class Tags < BasicSubcommand
      desc "get [ID] [--details]", "list all tags and their IDs"
      option :details, type: :boolean, default: false,
        desc: "Include additional tag info"
      def get(id = nil)
        app_options = OptionHelpers.get_options(options)
        logger.debug "tags.get(id=#{id || "none"}, details=#{options.details})"
        results = if options.details
          Lidarr::API::Tag.new(app_options).get_details(id)
        else
          Lidarr::API::Tag.new(app_options).get(id)
        end
        unless results.is_a?(Array)
          results = [results]
        end
        results.each do |result|
          puts result
        end
        # Output.print_results(options.format, results)
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
        app_options = OptionHelpers.get_options(options)
        paging_opts = OptionHelpers.thor_to_paging_options(options)
        logger.debug "missing(id=#{id || "none"}, include_artists=#{options.include_artists ? "true" : "false"}, pager=#{paging_opts})"
        results = Lidarr::API::Wanted.new(app_options).missing(id: id, include_artist: options.include_artist, paging_resource: paging_opts)
        Output.print_results(options.format, results)
      end
    end # end class Wanted

    class App < Thor
      class_option :api_key, type: :string, aliases: "-K",
        banner: "API_KEY",
        desc: "The API key to use with each request"
      class_option :config, type: :string, aliases: "-C",
        desc: "Configuration file with common options such as your api_key"
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

      desc "tags SUBCOMMAND [OPTIONS] [ARGS]", "work with tags"
      subcommand "tags", Tags

      desc "wanted SUBCOMMAND [OPTIONS] [ARGS]", "work with missing or cutoff albums"
      subcommand "wanted", Wanted
    end # end class App
  end # end module CLI
end
