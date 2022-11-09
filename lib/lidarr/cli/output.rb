# frozen_string_literal: true

require "mustache"

require_relative "output_plain"
require_relative "../logging"

module Lidarr
  module CLI
    module Output
      extend self

      def print_results options, results
        if options.format?
          print_custom_results options.format, results
        elsif options.output == "plain"
          Plain.print_results results
        elsif options.output == "json"
          print_json results
        elsif options.output == "yml"
          print_yml results
        else
          Lidarr.logger.fatal "No support for format #{output}"
        end
      end

      def print_custom_results format, results
        with_each_result(results) { |r| puts(Mustache.render(format, r.to_h)) }
      end

      def print_json results
        with_type_in_results(results) { |res| puts(JSON.pretty_generate(res)) }
      end

      def print_yml results
        with_type_in_results(results) { |res| puts(YAML.dump(res)) }
      end

      protected

      def with_type_in_results results, &block
        with_results(results) do |res|
          type = case res.first
          when Lidarr::API::AlbumResource
            "albums"
          when Lidarr::API::ArtistResource
            "artists"
          when Lidarr::API::BlocklistResource
            "blocklist"
          when Lidarr::API::TagDetailsResource
            "tags"
          when Lidarr::API::TagResource
            "tags"
          else
            Lidarr.logger.fatal "Unknown result type"
            exit 1
          end
          block.call({type => res.map(&:to_h)})
        end
      end

      def with_results results, &block
        if results.is_a?(Lidarr::API::PagingResource)
          results = results.records
        end
        results = Array(results)

        if results.empty?
          Lidarr.logger.debug "No results"
          return
        end

        block.call(results)
      end

      def with_each_result results, &block
        with_results(results) do |res|
          res.each do |r|
            block.call(r)
          end
        end
      end
    end # end module Output
  end # end module CLI
end # end module Lidarr
