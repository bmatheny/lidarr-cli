# frozen_string_literal: true

require_relative "helpers"

module Lidarr
  module CLI
    module Views
      module ArtistView
        include ViewHelpers

        def fn_short_artist_name
          truncate(artistName, 16)
        end

        def fn_best_id
          if mbId.nil? || mbId.empty?
            foreignArtistId
          else
            mbId
          end
        end

        def fn_last_album
          _clean_album lastAlbum
        end

        def fn_next_album
          _clean_album nextAlbum
        end

        private

        def _clean_album maybe_album, max_length = 24
          return nil if maybe_album.nil?
          truncate("#{maybe_album.id}|#{maybe_album.title}", max_length)
        end
      end # module ArtistView
    end
  end
end
