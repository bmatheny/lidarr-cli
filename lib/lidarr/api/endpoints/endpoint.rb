# frozen_string_literal: true

require_relative "../../mixins"
require_relative "../../options"
require "httparty"

module Lidarr
  module API
    class Endpoint
      include Lidarr::Mixins

      def initialize opts
        require_type(opts, Lidarr::Options)
        @opts = opts
      end

      protected

      attr_accessor :opts

      def party_opts
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
    end # end class Endpoint
  end # end module API
end
