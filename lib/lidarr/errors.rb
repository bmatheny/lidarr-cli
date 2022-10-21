# frozen_string_literal: true

module Lidarr
  class Error < StandardError; end

  class ExpectationFailedError < Error; end

  class HttpError < Error
    attr_reader :response

    # StandardError provides message method
    def initialize(msg, http_response)
      super(msg)
      @response = http_response
    end
  end

  class WellFormedHttpError < HttpError; end
end
