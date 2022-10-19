# frozen_string_literal: true

require_relative "../lidarr"
require "uri"

module Lidarr
  class Options
    include Lidarr::Mixins

    attr_reader :api_key, :headers, :logger, :secure, :url, :verbose

    def initialize
      @api_key = Lidarr.None
      @headers = {}
      @logger = Lidarr::Logging.get progname: "lidarr"
      @secure = Lidarr.None
      @url = Lidarr.None
      @verbose = Lidarr.None
    end

    def api_key= key
      @api_key = validate_non_empty "api_key", key
    end

    def headers= maybe_hdr
      name, value = validate_non_empty("header", maybe_hdr).map do |hdr|
        raise ExpectationFailedError.new("Invalid header, should be of form NAME:VALUE") unless /.+:.+/.match?(hdr)
        hdr.split(":")
      end.get
      @headers[name.strip] = value.strip
    end

    def secure= s
      @secure = Lidarr::Some(to_bool(s))
    end

    def url= url
      @url = validate_non_empty("url", url).map do |u|
        uri = URI.parse(u)
        if uri.is_a?(URI::HTTP)
          u
        else
          raise ExpectationFailedError.new("URL #{url} is not well formed and could not be parsed")
        end
      end
    end

    def verbose= v
      vb = to_bool(v)
      if vb
        @logger.more_verbose
      else
        @logger.less_verbose
      end
      @verbose = Lidarr::Some(vb)
    end

    def merge other
      require_that other.is_a?(Lidarr::Options), "must be Lidarr::Options"
      other.api_key.each ->(e) { self.api_key = e }
      other.headers.each do |k, v|
        @headers[k] = v
      end
      other.secure.each ->(e) { self.secure = e }
      other.url.each ->(e) { self.url = e }
      other.verbose.each ->(e) { self.verbose = e }
      self
    end

    private

    def validate_non_empty name, value
      msg = "#{name} must be a non-empty string"
      Lidarr::Option(value)
        .map { |e| e.to_s }
        .filter_not { |e| e.empty? }
        .or_else { raise ExpectationFailedError.new(msg) }
    end
  end # end class Options
end # end module Lidarr
