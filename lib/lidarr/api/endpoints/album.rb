# frozen_string_literal: true

require_relative "endpoint"

module Lidarr
  module API
    class Album < Endpoint
      URI = "/api/v1/album"

      # PUT /api/v1/album/monitor, payload {albumIds: [ID], monitored: false}
      def monitor album_ids
        require_type album_ids, Array
        response = make_monitor_request(album_ids, true)
        response.map do |rec|
          AlbumResource.from_record(rec)
        end
      end

      def unmonitor album_ids
        require_type album_ids, Array
        response = make_monitor_request(album_ids, false)
        response.map do |rec|
          AlbumResource.from_record(rec)
        end
      end

      def search(term)
        uri = "#{opts.url.get}#{URI}/lookup"
        http_options = party_opts
        http_options[:query][:term] = term
        res = HTTParty.get(uri, http_options).parsed_response
        res.map { |rec| AlbumResource.from_record(rec) }
      end

      private

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
