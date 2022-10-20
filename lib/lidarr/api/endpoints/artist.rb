# frozen_string_literal: true

require_relative "endpoint"

module Lidarr
  module API
    class Artist < Endpoint
      URI = "/api/v1/artist"

      # GET path /api/v1/artist/{id}
      #     Response ArtistResource
      # GET path /api/v1/artist
      #     Response Array<ArtistResource>
      def get(id)
        uri = "#{opts.url.get}#{URI}"
        http_options = party_opts

        if is_uuid(id)
          http_options[:query][:mbId] = id
        else
          uri = "#{uri}/#{id}"
        end

        res = HTTParty.get(uri, http_options).parsed_response
        pp res
        if is_uuid(id)
          res.map { |r| ArtistResource.new.populate(r) }
        else
          ArtistResource.new.populate(res)
        end
      end

      def list
        uri = "#{opts.url.get}#{URI}"
        http_options = party_opts

        res = HTTParty.get(uri, http_options).parsed_response
        res.map { |r| ArtistResource.new.populate(r) }
      end

      def search(term)
        uri = "#{opts.url.get}#{URI}/lookup"
        http_options = party_opts
        http_options[:query][:term] = term
        res = HTTParty.get(uri, http_options).parsed_response
        res.map { |r| ArtistResource.new.populate(r) }
      end

      private

      def is_uuid(uuid)
        uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
        uuid_regex.match?(uuid.to_s.downcase)
      end
    end # end class Artist
  end # end module API
end
