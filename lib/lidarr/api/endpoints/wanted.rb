# frozen_string_literal: true

require_relative "endpoint"

module Lidarr
  module API
    class Wanted < Endpoint
      # GET path /api/v1/wanted/missing/{id}
      #     response: AlbumResource
      # GET path /api/v1/wanted/missing
      #     response: Array<AlbumResource>
      def missing(id: nil, include_artist: false, paging_resource: nil)
        make_request :get, path: "/missing#{make_id_path(id)}", http_options: make_http_options(include_artist, paging_resource)
      end

      # GET path /api/v1/wanted/cutoff/{id}
      #     response: AlbumResource
      # GET path /api/v1/wanted/cutoff
      #     response: Array<AlbumResource>
      def cutoff(id: nil, include_artist: false, paging_resource: nil)
        make_request :get, path: "/cutoff#{make_id_path(id)}", http_options: make_http_options(include_artist, paging_resource)
      end

      protected

      def get_uri
        "/api/v1/wanted"
      end

      def process_2xx_response response
        res = response.parsed_response
        if res.key?("records")
          PagingResource.from_response(res) { |r| AlbumResource.from_record(r) }
        else
          make_array(res).map { |r| AlbumResource.from_record(r) }
        end
      end

      private

      def make_http_options(include_artist, paging_resource)
        hopts = if paging_resource
          party_opts(paging_resource.get_query)
        else
          party_opts
        end
        if include_artist
          hopts[:query][:includeArtist] = "true"
        end
        hopts
      end
    end # end class Wanted
  end
end
