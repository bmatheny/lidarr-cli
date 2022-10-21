# frozen_string_literal: true

require_relative "endpoint"

module Lidarr
  module API
    class Artist < Endpoint
      # GET path /api/v1/artist/{id}
      #     Response ArtistResource
      def get(id)
        uri = is_uuid(id) ? "" : make_id_path(id)
        hopts = party_opts
        if is_uuid(id)
          hopts[:query][:mbId] = id
        end
        make_request :get, path: uri, http_options: hopts
      end

      # GET path /api/v1/artist
      #     Response Array<ArtistResource>
      def list
        make_request :get
      end

      def search(term)
        make_request :get, path: "/lookup", http_options: party_opts(term: term)
      end

      protected

      def get_uri
        "/api/v1/artist"
      end

      def process_2xx_response response
        make_array(response.parsed_response).map { |r| ArtistResource.new.populate(r) }
      end

      private

      def is_uuid(uuid)
        uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
        uuid_regex.match?(uuid.to_s.downcase)
      end
    end # end class Artist
  end # end module API
end
