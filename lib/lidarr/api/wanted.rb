# frozen_string_literal: true

require "httparty"

module Lidarr
  module API
    class Wanted
      URI = "/api/v1/wanted"

      def initialize opts
        @opts = opts
      end

      def missing include_artist = false, paging_resource = nil
        party_options = party_opts(@opts)
        response = HTTParty.get("#{@opts.url.get}#{URI}/missing", party_options)
        pp response
      end

      def party_opts opts
        headers = opts.headers
        headers["x-api-key"] = opts.api_key.get
        {
          headers: headers,
          verify: false,
          verbose: opts.verbose.get_or_else(false)
        }
      end
    end # end class Wanted
  end
end
