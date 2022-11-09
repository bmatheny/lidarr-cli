# frozen_string_literal: true

require_relative "../api"
require_relative "../data"
require_relative "../logging"
require_relative "../mixins"
require_relative "views"

require "mustache"
require "thor"

module Lidarr
  module CLI
    module Output
      module Plain
        extend self

        include Lidarr::Mixins

        def print_results results
          paging = nil
          if results.is_a?(Lidarr::API::PagingResource)
            paging = results.to_h
            results = results.records
          end
          results = Array(results)

          if results.empty?
            Lidarr.logger.debug "No results"
            return
          end

          case peek(results)
          when Lidarr::API::AlbumResource
            puts render(:albums, results, Views::NoOp, paging: paging)
          when Lidarr::API::ArtistResource
            puts render(:artists, results, Views::ArtistView)
          when Lidarr::API::BlocklistResource
            puts render(:blocklist, results, Views::NoOp, paging: paging)
          when Lidarr::API::TagDetailsResource
            puts render(:tagdetails, results, Views::TagDetailsView)
          when Lidarr::API::TagResource
            puts render(:tags, results)
          else
            Lidarr.logger.fatal "Unknown result type: #{peek(results)}"
          end
        end # print_results

        private

        def render name, results, results_extended_by = Views::NoOp, new_methods = {}
          view = Views::MustacheView.new
          results.each { |row| row.extend(results_extended_by) }
          view.define_singleton_method(name) { results }
          new_methods.each do |method_name, return_value|
            view.define_singleton_method(method_name) { return_value }
          end
          view.render(name)
        end

        def peek results
          results.first
        end
      end # Plain module
    end # Output module
  end # CLI module
end # Lidarr module
