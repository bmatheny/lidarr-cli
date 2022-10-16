# frozen_string_literal: true

require "lidarr/errors"

module Lidarr
  module Mixins
    def self.included base
      base.extend(Lidarr::Mixins)
    end

    # Create a deep copy of a hash
    #
    # This is useful for copying a hash that will be mutated
    # @note All keys and values must be serializable, Proc for instance will fail
    # @param [Hash] hash the hash to copy
    # @return [Hash]
    def deep_copy_hash hash
      require_that(hash.is_a?(Hash), "deep_copy_hash requires a hash be specified, got #{hash.class}")
      Marshal.load Marshal.dump(hash)
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

    # Given a hash, rewrite keys to symbols
    #
    # @param [Hash] hash the hash to symbolize
    # @param [Hash] options specify how to process the hash
    # @option options [Boolean] :rewrite_regex if the value is a regex and this is true, convert it to a string
    # @option options [Boolean] :downcase if true, downcase the keys as well
    # @raise [ExpectationFailedError] if hash is not a hash
    def symbolize_hash hash, options = {}
      return {} if hash.nil? || hash.empty?
      raise ExpectationFailedError.new("symbolize_hash called without a hash") unless hash.is_a?(Hash)
      hash.each_with_object({}) do |(k, v), result|
        key = options[:downcase] ? k.to_s.downcase.to_sym : k.to_s.to_sym
        result[key] = if v.is_a?(Hash)
          symbolize_hash(v)
        elsif v.is_a?(Regexp) && options.fetch(:rewrite_regex, false)
          v.inspect[1..-2]
        else
          v
        end
        result
      end
    end

    # Returns false if the value provided is not truthy, and true otherwise
    #
    # @param [Object] value the value to be checked
    # @return [Boolean] boolean representation of value
    def to_bool value
      ![false, nil, 0, ""].include?(value)
    end

    # This provides access to these methods via a Lidarr::Mixins.method_name call
    [:deep_copy_hash, :require_that, :require_type, :symbolize_hash, :to_bool].each do |method|
      module_function method
      public method # without this, module_function makes the method private
    end
  end # end module Mixins
end # end module Lidarr
