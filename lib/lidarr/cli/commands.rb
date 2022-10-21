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
      include Lidarr::Mixins

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
        require_that(ids.size > 0, "Need to specify at least one ID")
        make_request "abum.unmonitor(#{ids.join(",")})", ->(a) { a.monitor(ids) }
      end

      desc "unmonitor IDs", "Unset the monitor bit for an album with id ID"
      def unmonitor(*ids)
        require_that(ids.size > 0, "Need to specify at least one ID")
        make_request "abum.unmonitor(#{ids.join(",")})", ->(a) { a.unmonitor(ids) }
      end

      desc "get_by_artist_id ARTIST_ID", "Fetch albums by artist ID"
      def get_by_artist_id(artist_id)
        make_request "album.get_by_artist_id(#{artist_id})", ->(a) { a.get(artist_id: artist_id) }
      end

      desc "get_by_album_id IDs", "Specify one or more IDs separated by spaces"
      def get_by_album_id(*ids)
        require_that(ids.size > 0, "Need to specify at least one ID")
        make_request "album.get_by_album_id(#{ids.join(",")})", ->(a) { a.get(album_ids: ids) }
      end

      desc "get_by_foreign_album_id ID", "Fetch album ID by foreign album ID"
      def get_by_foreign_album_id(id)
        make_request "album.get_by_foreign_album_id(#{id})", ->(a) { a.get(foreign_album_id: id) }
      end

      desc "search TERM", "search for albums"
      def search(term)
        make_request "album.search(term=#{term})", ->(a) { a.search(term) }
      end

      private

      no_commands do
        def make_request from, block
          app_options = OptionHelpers.get_options(options)
          Lidarr.logger.debug from
          app = Lidarr::API::Album.new(app_options)
          results = block.call(app)
          Output.print_results(options.output, results)
        end
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
        make_request "artist.get(id=#{id})", ->(a) { a.get(id) }
      end

      desc "list", "list all artists and associated attributes"
      def list
        make_request "artist.list()", ->(a) { a.list }
      end

      desc "search TERM", "search for artists"
      def search(term)
        make_request "artist.search(term=#{term})", ->(a) { a.search(term) }
      end

      private

      no_commands do
        def make_request from, block
          app_options = OptionHelpers.get_options(options)
          Lidarr.logger.debug from
          app = Lidarr::API::Artist.new(app_options)
          results = block.call(app)
          Output.print_results(options.output, results)
        end
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
      class_option :include_artist, type: :boolean, default: false,
        desc: "Include artist info"

      desc "cutoff [ID]", "Get albums with an unmet cutoff"
      long_desc <<-LONGDESC
      Get albums you have which for one reason or another do not meet their specified cutoff.

      If you provide an ID, it is expected that you are querying about a specific
      album. The ID is optional.

      If you pass --include-artist, each row will have additional detail.

      Takes standard pagination options as well.
      LONGDESC
      def cutoff(id = nil)
        make_request(:cutoff, id)
      end

      desc "missing [ID]", "Get missing albums"
      long_desc <<-LONGDESC
      Get missing albums.

      If you provide an ID, it is expected that you are querying about a specific
      album. The ID is optional.

      If you pass --include-artist, each row will have additional detail.

      Takes standard pagination options as well.
      LONGDESC
      def missing(id = nil)
        make_request(:missing, id)
      end

      private

      no_commands do
        def make_from src, maybe_id, paging_opts
          id = maybe_id || "none"
          artists = to_bool(options.include_artists).to_s
          "#{src}(id=#{id}, include_artists=#{artists}, pager=#{paging_opts})"
        end

        def make_request src, id
          app_options = OptionHelpers.get_options(options)
          paging_opts = OptionHelpers.thor_to_paging_options(options)
          Lidarr.logger.debug make_from(src.to_s, id, paging_opts)
          app = Lidarr::API::Wanted.new(app_options)
          results = app.send(src, id: id, include_artist: options.include_artist, paging_resource: paging_opts)
          Output.print_results(options.output, results)
        end
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
