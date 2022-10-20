# frozen_string_literal: true

require_relative "endpoint"

module Lidarr
  module API
    class Wanted < Endpoint
      URI = "/api/v1/wanted"

      # ?page=1&pageSize=20&sortDirection=descending&sortKey=releaseDate&monitored=true
      def missing(id: nil, include_artist: false, paging_resource: nil)
        ret = nil
        res = make_request(id, include_artist, paging_resource)
        if res.is_a?(Hash)
          if id.nil? && res.key?("records")
            ret = PagingResource.from_response(res) do |rec|
              AlbumResource.from_record(rec)
            end
          elsif id
            ret = AlbumResource.from_record(res)
          end
        end
        ret
      end

      private

      def make_request id, include_artist, paging_resource
        http_opts = wanted_opts(include_artist, paging_resource)
        uri = "#{@opts.url.get}#{URI}/missing"
        if id
          uri = "#{uri}/#{id}"
        end
        # TODO error handling
        res = HTTParty.get(uri, http_opts)
        res.parsed_response
      end

      def wanted_opts include_artist, paging_resource
        party_options = party_opts
        if paging_resource
          party_options[:query].merge!(paging_resource.get_query)
        end
        if include_artist
          party_options[:query][:includeArtist] = "true"
        end
        party_options
      end
    end # end class Wanted
  end
end
