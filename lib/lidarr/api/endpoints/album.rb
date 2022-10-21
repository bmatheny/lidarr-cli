# frozen_string_literal: true

require_relative "endpoint"

module Lidarr
  module API
    class Album < Endpoint
      URI = "/api/v1/album"

      # PUT /api/v1/album/monitor, payload {albumIds: [ID], monitored: false}
      def monitor(album_ids)
        require_type album_ids, Array
        response = make_monitor_request(album_ids, true)
        response.map do |rec|
          AlbumResource.from_record(rec)
        end
      end

      def unmonitor(album_ids)
        require_type album_ids, Array
        response = make_monitor_request(album_ids, false)
        response.map do |rec|
          AlbumResource.from_record(rec)
        end
      end

      def get(artist_id: nil, album_ids: nil, foreign_album_id: nil, include_all_artist_albums: false)
        uri = "#{opts.url.get}#{URI}"
        http_options = party_opts
        http_options[:query][:artistId] = artist_id unless artist_id.nil?
        http_options[:query][:albumIds] = make_array(album_ids) unless album_ids.nil?
        http_options[:query][:foreignAlbumId] = foreign_album_id unless foreign_album_id.nil?
        http_options[:query][:includeAllArtistAlbums] = include_all_artist_albums if include_all_artist_albums
        http_options[:query_string_normalizer] = ->(query) {
          query.map { |key, value| value.map { |v| "#{key}=#{v}" } }.join("&")
        }
        res = HTTParty.get(uri, http_options).parsed_response
        res.map { |rec| AlbumResource.from_record(rec) }
      end

      def search(term)
        uri = "#{opts.url.get}#{URI}/lookup"
        http_options = party_opts
        http_options[:query][:term] = term
        res = HTTParty.get(uri, http_options).parsed_response
        res.map { |rec| AlbumResource.from_record(rec) }
      end

      private

      def make_array ids
        ids.is_a?(Array) ? ids : [ids]
      end

      def make_monitor_request album_ids, monitored
        http_options = party_opts
        http_options[:query].merge!({albumIds: album_ids, monitored: monitored})
        uri = "#{@opts.url.get}#{URI}/monitor"
        http_options[:body] = http_options.delete(:query).to_json
        res = HTTParty.put(uri, http_options)
        res.parsed_response
      end
    end
  end # module API
end
