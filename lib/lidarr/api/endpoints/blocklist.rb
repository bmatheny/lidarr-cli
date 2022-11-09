# frozen_string_literal: true

require_relative "endpoint"

module Lidarr
  module API
    class Blocklist < Endpoint
      # GET path /api/v1/blocklist
      def list(paging_resource = nil)
        make_request :get, http_options: make_http_options(paging_resource)
      end

      # DELETE path /api/v1/blocklist/bulk
      def delete(ids)
        require_type(ids, Array)
        opts = party_opts(ids: ids)
        opts[:body] = opts.delete(:query).to_json
        make_request :delete, path: "/bulk", http_options: opts
      end

      protected

      def get_uri
        "/api/v1/blocklist"
      end

      def process_2xx_response response
        res = response.parsed_response
        if res.empty? and response.code == 200
          return nil
        end
        if res.key?("records")
          PagingResource.from_response(res) { |r| BlocklistResource.from_record(r) }
        else
          make_array(res).map { |r| BlocklistResource.from_record(r) }
        end
      end

      private

      def make_http_options(paging_resource)
        if paging_resource
          party_opts(paging_resource.get_query)
        else
          party_opts
        end
      end
    end
  end
end
