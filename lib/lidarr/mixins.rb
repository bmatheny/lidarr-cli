# frozen_string_literal: true

require "lidarr/errors"

module Lidarr
  module Mixins
    def self.included base
      base.extend(Lidarr::Mixins)
    end

    # Require that a guard condition passes
    #
    # @param [Boolean] guard condition that should be true
    # @param [String] the message to use if the guard condition fails
    # @raise [ExpectationFailedError] if the guard condition fails
    def require_that guard, message
      raise ExpectationFailedError.new(message) unless guard
    end

    # Require that a value is of the specified type
    #
    # @param [Object] value the value to be checked
    # @param [Class] the expected type of the value
    # @raise [ArgumentError] if the value is not of the specified type
    def require_type value, type
      unless value.is_a?(type)
        raise ArgumentError.new("expected type #{type}, got type #{value.class}")
      end
    end
  end # end module Mixins
end # end module Lidarr
