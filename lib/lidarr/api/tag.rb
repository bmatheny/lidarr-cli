# frozen_string_literal: true

require_relative "endpoint"
require_relative "tag_resource"

module Lidarr
  module API
    class Tag < Endpoint
      URI = "/api/v1/tag"

      # PUT, body
      def create(tag_resource)
        # PUT /api/v1/tag/{id}
        # Body is TagResource (TODO lookup)
        # Response: TagResource
      end

      # DELETE, path /api/v1/tag/{id}
      def delete(id = nil)
      end

      # GET path /api/v1/tag/{id}
      #     Response TagResource
      # GET path /api/v1/tag
      #     Response Array<TagResource>
      def get(id = nil)
        uri = "#{opts.url.get}#{URI}"
        uri = "#{uri}/#{id}" unless id.nil?

        http_options = party_opts
        res = HTTParty.get(uri, http_options).parsed_response
        if id.nil?
          res.map { |r| TagResource.new.populate(r) }
        else
          TagResource.new.populate(res)
        end
      end

      # GET path /api/v1/tag/detail/{id}
      #     Response: TagDetailsResource
      # GET path /api/v1/tag/detail
      #     Response: Array<TagDetailsResource>
      # TagDetailsResource does include an array of artistIds (along with a bunch fo stuff we can't
      # use)
      def get_details(id = nil)
        uri = "#{opts.url.get}#{URI}/detail"
        uri = "#{uri}/#{id}" unless id.nil?

        http_options = party_opts
        res = HTTParty.get(uri, http_options).parsed_response
        if id.nil?
          res.map { |r| TagDetailsResource.new.populate(r) }
        else
          TagDetailsResource.new.populate(res)
        end
      end

      # POST /api/v1/tag
      # BODY is TagResource
      # Response is TagResource
      def update(tag_resource)
      end
    end
  end # end API module
end
