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
        Output.print_results(options.output, results)
      end

      desc "unmonitor IDs", "Unset the monitor bit for an album with id ID"
      def unmonitor(*ids)
        app_options = OptionHelpers.get_options(options)
        results = Lidarr::API::Album.new(app_options).unmonitor(ids)
        Output.print_results(options.output, results)
      end

      desc "search TERM", "search for albums"
      def search(term)
        app_options = OptionHelpers.get_options(options)
        Lidarr.logger.debug "album.search(term=#{term})"
        results = Lidarr::API::Album.new(app_options).search(term)
        Output.print_results(options.output, results)
      end
    end

    class Artist < PagedSubcommand
      desc "get ID", "get artist attributes"
      long_desc <<-LONGDESC
      Get an artist

      If a numeric ID is specified, the artist with that ID is returned.
      If a UUID is specified, the artist with that music brainz ID is returned.

      Takes standard pagination options as well.
      LONGDESC
      def get(id)
        app_options = OptionHelpers.get_options(options)
        Lidarr.logger.debug "artist.get(id=#{id})"
        results = Lidarr::API::Artist.new(app_options).get(id)
        Output.print_results(options.output, results)
      end

      desc "list", "list all artists and associated attributes"
      def list
        app_options = OptionHelpers.get_options(options)
        Lidarr.logger.debug "artist.list"
        results = Lidarr::API::Artist.new(app_options).list
        Output.print_results(options.output, results)
      end

      desc "search TERM", "search for artists"
      def search(term)
        app_options = OptionHelpers.get_options(options)
        Lidarr.logger.debug "artist.search(term=#{term})"
        results = Lidarr::API::Artist.new(app_options).search(term)
        Output.print_results(options.output, results)
      end
    end

    class Tag < BasicSubcommand
      desc "get [ID] [--details]", "list all tags and their IDs"
      option :details, type: :boolean, default: false,
        desc: "Include additional tag info"
      def get(id = nil)
        app_options = OptionHelpers.get_options(options)
        Lidarr.logger.debug "tag.get(id=#{id || "none"}, details=#{options.details})"
        results = if options.details
          Lidarr::API::Tag.new(app_options).get_details(id)
        else
          Lidarr::API::Tag.new(app_options).get(id)
        end
        Output.print_results(options.output, results)
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
        Lidarr.logger.debug "missing(id=#{id || "none"}, include_artists=#{options.include_artists ? "true" : "false"}, pager=#{paging_opts})"
        results = Lidarr::API::Wanted.new(app_options).missing(id: id, include_artist: options.include_artist, paging_resource: paging_opts)
        Output.print_results(options.output, results)
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
      # TODO add format option, allow specifying custom format instead of depending on canned output
      class_option :output, type: :string, aliases: "-O",
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

      desc "artist SUBCOMMAND [OPTIONS] [ARGS]", "work with artists"
      subcommand "artist", Artist

      desc "tag SUBCOMMAND [OPTIONS] [ARGS]", "work with tags"
      subcommand "tag", Tag

      desc "wanted SUBCOMMAND [OPTIONS] [ARGS]", "work with missing or cutoff albums"
      subcommand "wanted", Wanted
    end # end class App
  end # end module CLI
end
