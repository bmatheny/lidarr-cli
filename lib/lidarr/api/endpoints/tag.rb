# frozen_string_literal: true

require_relative "endpoint"
require_relative "../resources/tag_resource"

module Lidarr
  module API
    class Tag < Endpoint
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
        make_request :get, path: make_id_path(id)
      end

      # GET path /api/v1/tag/detail/{id}
      #     Response: TagDetailsResource
      # GET path /api/v1/tag/detail
      #     Response: Array<TagDetailsResource>
      # TagDetailsResource does include an array of artistIds (along with a bunch fo stuff we can't
      # use)
      def get_details(id = nil)
        make_request :get, path: "/detail#{make_id_path(id)}"
      end

      # POST /api/v1/tag
      # BODY is TagResource
      # Response is TagResource
      def update(tag_resource)
      end

      protected

      def get_uri
        "/api/v1/tag"
      end

      def process_2xx_response response
        if response.request.path.to_s.include?("/detail")
          make_array(response.parsed_response).map { |r| TagDetailsResource.new.populate(r) }
        else
          make_array(response.parsed_response).map { |r| TagResource.new.populate(r) }
        end
      end
    end # end Tag class
  end # end API module
end
