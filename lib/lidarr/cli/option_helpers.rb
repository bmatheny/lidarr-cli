# frozen_string_literal: true

require_relative "../api/paging"
require_relative "option_sources"

module Lidarr
  module CLI
    module OptionHelpers
      extend self

      def get_options options
        default_files = ["/etc/lidarr-cli.yml", File.expand_path("~/.config/lidarr/cli.yml")]
        opts = OptionSources.files_to_options(default_files)
        opts.merge(OptionSources.env_to_options(ENV.to_hash))
        opts.merge(OptionSources.file_to_options(ENV["LIDARR_CONFIG"])) if ENV.key?("LIDARR_CONFIG")
        opts.merge(OptionSources.file_to_options(options.config)) if options.config?
        opts.merge(OptionSources.thor_to_options(options))
      end

      def thor_to_paging_options options
        Lidarr::API::PagingRequest.new(
          page: options.fetch("page", nil),
          page_size: options.fetch("page_size", nil),
          sort_key: options.fetch("sort_key", nil),
          sort_direction: options.fetch("sort_direction", nil),
          filters: options.fetch("filters", nil)
        )
      end
    end
  end
end
