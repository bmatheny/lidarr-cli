# frozen_string_literal: true

require "httparty"
require_relative "../mixins"

module Lidarr
  module API
    class Album
      include Lidarr::Mixins

      URI = "/api/v1/album"

      def initialize opts
        @opts = opts
      end

      # PUT /api/v1/album/monitor, payload {albumIds: [ID], monitored: false}
      def monitor album_ids
        require_type album_ids, Array
        response = make_request(album_ids, true)
        response.map do |rec|
          AlbumResource.from_record(rec)
        end
      end

      def unmonitor album_ids
        require_type album_ids, Array
        response = make_request(album_ids, false)
        response.map do |rec|
          AlbumResource.from_record(rec)
        end
      end

      def make_request album_ids, monitored
        http_options = party_opts(@opts)
        http_options[:query].merge!({albumIds: album_ids, monitored: monitored})
        uri = "#{@opts.url.get}#{URI}/monitor"
        http_options[:body] = http_options.delete(:query).to_json
        res = HTTParty.put(uri, http_options)
        res.parsed_response
      end

      def party_opts opts
        headers = opts.headers
        headers["x-api-key"] = opts.api_key.get
        headers["Content-Type"] = "application/json"
        {
          headers: headers,
          verify: opts.secure.get_or_else(true),
          verbose: opts.verbose.get_or_else(false),
          query: {}
        }
      end
    end
  end # module API
end
