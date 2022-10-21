# frozen_string_literal: true

require_relative "endpoint"

module Lidarr
  module API
    class Album < Endpoint
      # PUT /api/v1/album/monitor, payload {albumIds: [ID], monitored: false}
      def monitor(album_ids)
        make_monitor_request(album_ids, true)
      end

      def unmonitor(album_ids)
        make_monitor_request(album_ids, false)
      end

      # TODO Add list for when get is called with no arguments
      def get(artist_id: nil, album_ids: nil, foreign_album_id: nil, include_all_artist_albums: false)
        hopt = {}
        hopt[:artistId] = artist_id unless artist_id.nil?
        hopt[:albumIds] = Array(album_ids) unless album_ids.nil?
        hopt[:foreignAlbumId] = foreign_album_id unless foreign_album_id.nil?
        hopt[:includeAllArtistAlbums] = include_all_artist_albums if include_all_artist_albums
        make_request :get, http_options: party_opts(hopt)
      end

      def search(term)
        make_request :get, path: "/lookup", http_options: party_opts(term: term)
      end

      protected

      def get_uri
        "/api/v1/album"
      end

      def process_2xx_response response
        make_array(response.parsed_response).map { |r| AlbumResource.new.populate(r) }
      end

      private

      def make_monitor_request album_ids, monitored
        require_type(album_ids, Array)
        http_options = party_opts(albumIds: album_ids, monitored: monitored)
        http_options[:body] = http_options.delete(:query).to_json
        make_request :put, path: "/monitor", http_options: http_options
      end
    end
  end # module API
end
