# frozen_string_literal: true

require_relative "../../errors"
require_relative "../../mixins"
require_relative "../../options"

require "erb"
require "httparty"
require "json"

module Lidarr
  module API
    # Handle errors properly
    class LidarrHttpParser < HTTParty::Parser
      SupportedFormats.merge!(
        {"application/problem+json" => :json}
      )
    end

    class Endpoint
      include Lidarr::Mixins

      # This is a slightly modified version of JSON_API_QUERY_STRING_NORMALIZER made to work with
      # the lidarr server
      LIDARR_QUERY_STRING_NORMALIZER = proc do |query|
        Array(query).sort_by { |a| a[0].to_s }.map do |key, value|
          if value.nil?
            key.to_s
          elsif value.respond_to?(:to_ary)
            value.to_ary.map { |v| "#{key}=#{ERB::Util.url_encode(v.to_s)}" }.join("&")
          else
            HTTParty::HashConversions.to_params(key => value)
          end
        end.flatten.join("&")
      end

      def initialize opts
        require_type(opts, Lidarr::Options)
        @opts = opts
      end

      protected

      attr_accessor :opts

      def get_uri
        raise NotImplementedError.new("get_uri not implemented on #{self.class}")
      end

      def process_2xx_response response
        raise NotImplementedError.new("process_2xx_response not implemented")
      end

      # Lidarr responds with a 404 intentionally to let you know the resource you described doesn't
      # exist. These should be handled properly.
      def expected_error404_handler response
        res = response.parsed_response
        if res.is_a?(Hash) && res.key?("message") && res.key?("description")
          msg = %(The ID you specified was likely invalid. Additional info: #{res["message"]})
          raise WellFormedHttpError.new(msg, response)
        else
          generic_error_handler(response)
        end
      end

      def wellformed_error_handler title, errors, response
        errs = errors.map { |key, msgs| "#{key}: #{msgs.join(", ")}" }.join(". ")
        raise WellFormedHttpError.new("Error processing request. #{title} Please address the following errors: #{errs}", response)
      end

      def generic_error_handler response
        msg = %(HTTP error, response code #{response.code} for #{self.class}. Possible message was #{response.parsed_response.to_s[0...80]})
        raise HttpError.new(msg, response)
      end

      # All paths through this raise an exception, calling generic_error_handler or
      # wellformed_error_handler whichever is appropriate
      def error_processor response
        parsed = response.parsed_response
        if parsed.is_a?(Hash) && parsed.key?("title") && parsed.key?("errors")
          if parsed["errors"].is_a?(Hash)
            wellformed_error_handler(parsed["title"], parsed["errors"], response)
          else
            raise NotImplementedError.new("Can only handle hash of errors, not #{parsed["errors"].class} errors")
          end
        else
          generic_error_handler(response)
        end
      end

      def make_request method, path: "", http_options: {}, handlers: {}
        uri = "#{opts.url.get}#{get_uri}#{path}"
        Lidarr.logger.trace "Making request to: #{uri}"
        hopts = http_options.empty? ? party_opts : http_options
        response = HTTParty.send(method.to_sym, uri, hopts)
        get_handler(response, handlers).call(response)
      end

      def party_opts with_query = {}
        headers = opts.headers
        headers["x-api-key"] = opts.api_key.get
        headers["Content-Type"] = "application/json"
        {
          headers: headers,
          verify: opts.secure.get_or_else(true),
          verbose: opts.verbose.get_or_else(false),
          query: with_query,
          query_string_normalizer: LIDARR_QUERY_STRING_NORMALIZER,
          parser: LidarrHttpParser
        }
      end

      def get_handler response, handler_hash
        code = response.code
        if handler_hash.key?(code)
          handler_hash[code]
        elsif code == 404
          ->(response) { expected_error404_handler(response) }
        elsif code >= 400
          if handler_hash.key?(:error)
            handler_hash[:error]
          else
            ->(response) { error_processor(response) }
          end
        elsif handler_hash.key?(:success)
          handler_hash[:success]
        else
          ->(response) { process_2xx_response(response) }
        end
      end

      def make_id_path id
        if id.nil? || id.empty?
          ""
        else
          "/#{id}"
        end
      end

      def make_array maybe_array
        if maybe_array.is_a?(Array)
          maybe_array
        else
          [maybe_array]
        end
      end
    end # end class Endpoint
  end # end module API
end
