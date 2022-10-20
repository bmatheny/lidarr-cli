# frozen_string_literal: true

require_relative "../api/paging"
require_relative "../api/tag_resource"
require_relative "../logging"
require "thor"

module Lidarr
  module CLI
    module Output
      module Plain
        extend self

        def print_results results
          extras = nil
          if results.is_a?(Lidarr::API::PagingResource)
            extras = "Page: #{results.page}, Total Records: #{results.total_records}, Filters: #{results.filters.inspect}, Sort Key: #{results.sort_key}"
            results = results.records
          end
          results = [results] unless results.is_a?(Array)

          case peek(results)
          when Lidarr::API::AlbumResource
            print_album_resources results
          when Lidarr::API::TagResource
            print_tag_resources results
          else
            Lidarr.logger.fatal "Unknown result type: #{peek(results)}"
          end
          puts("")
          puts(extras) unless extras.nil?
        end # print_results

        def print_album_resources results
          print_structured_resource results, {
            headers: ["ID", "Artist Name", "Album Title", "Monitored", "Album Type", "Release Date"],
            generator: ->(res) { [res.id, res.artist.artistName, res.title, res.monitored, res.albumType, res.releaseDate] }
          }
        end

        def print_tag_resources results
          print_structured_resource results, {
            headers: ["ID", "Tag"],
            generator: ->(res) { [res.id, res.label] }
          }
        end

        private

        def print_structured_resource results, table_description
          # TODO: If results.size == 1 we want a vertical layout not a horizontal one
          shell = Thor::Shell::Basic.new
          rows = [table_description[:headers]]
          results.each do |res|
            rows << table_description[:generator].call(res)
          end
          shell.print_table(rows)
        end

        def peek results
          results.first
        end
      end # Plain module
    end # Output module
  end # CLI module
end # Lidarr module
