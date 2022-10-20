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
          if results.is_a?(Lidarr::API::PagingResource)
            extras = "Page: #{results.page}, Total Records: #{results.total_records}, Filters: #{results.filters.inspect}, Sort Key: #{results.sort_key}"
            results = results.records
          end
          results = make_array(results)

          case peek(results)
          when Lidarr::API::AlbumResource
            print_album_resources results
          when Lidarr::API::ArtistResource
            print_artist_resources results
          when Lidarr::API::TagDetailsResource
            print_tagdetails_resources results
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

        def print_artist_resources results
          print_structured_resource results, {
            headers: ["ID", "MB ID", "Artist Name", "Status", "Monitored (new?)", "Last Album", "Next Album"],
            generator: ->(res) { [res.id, choose_first([res.mbId, res.foreignArtistId]), truncate(res.artistName, 16), res.status, "#{res.monitored} (#{res.monitorNewItems})", get_album(res.lastAlbum), get_album(res.nextAlbum)] }
          }
        end

        def print_tag_resources results
          print_structured_resource results, {
            headers: ["ID", "Tag"],
            generator: ->(res) { [res.id, res.label] }
          }
        end

        def print_tagdetails_resources results
          print_structured_resource results, {
            headers: ["ID", "Tag", "Artist IDs", "Indexer IDs"],
            generator: ->(res) { [res.id, res.label, safe_join(res.artistIds), safe_join(res.indexerIds)] }
          }
        end

        private

        def choose_first ary
          ary.find(&:itself)
        end

        def get_album maybe_album, max_length = 16
          return "" if maybe_album.nil?
          truncate("#{maybe_album.id},#{maybe_album.title}", max_length)
        end

        def make_array value
          value.is_a?(Array) ? value : [value]
        end

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

        def safe_join value, join_str = ","
          value.nil? ? "" : make_array(value).join(join_str)
        end

        def truncate string, max
          if string.nil?
            ""
          elsif string.length > max
            "#{string[0...max]}..."
          else
            string
          end
        end
      end # Plain module
    end # Output module
  end # CLI module
end # Lidarr module
