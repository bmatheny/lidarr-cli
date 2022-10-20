# frozen_string_literal: true

require_relative "../api/paging"
require_relative "../api/tag_resource"
require "thor"

module Lidarr
  module CLI
    module Output
      extend self

      def print_results format, results
        pp results
        if format == "plain"
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
          puts "Unsupported format #{format}"
          exit 1
        end
      end
    end # end module Output
  end # end module CLI
end # end module Lidarr
