# frozen_string_literal: true

module Lidarr
  # Convenience method for creating an `Option`
  def self.Option value
    if value.nil?
      ::Lidarr::None()
    else
      ::Lidarr::Some(value)
    end
  end

  # Convenience method for creating a `None`
  def self.None
    ::Lidarr::None.new
  end

  # Convenience method for creating a `Some`
  def self.Some value
    ::Lidarr::Some.new(value)
  end

  # Represents optional values. Instances of `Option` are either an instance of `Some` or `None`
  # @note This is pretty much a straight rip off of the scala version
  # @example
  #   name = get_parameter("name")
  #   upper = Option(name).map{|s| s.strip}.filter{|s|s.size > 0}.map{|s|s.upcase}
  #   puts(upper.get_or_else(""))
  class Option
    # @return [Boolean] True if the value is undefined
    def empty?
      raise NotImplementedError.new("empty? not implemented")
    end

    # @return [Boolean] True if the value is defined
    def defined?
      !empty?
    end

    # @return [Object] Value, if defined
    # @raise [NameError] if value is undefined
    def get
      raise NotImplementedError.new("get not implemented")
    end

    # The value associated with this option, or the default
    #
    # @example
    #  # Raises an exception
    #  Option(nil).get_or_else { raise Exception.new("Stuff") }
    #  # Returns -1
    #  Option("23").map {|i| i.to_i}.filter{|i| i > 25}.get_or_else -1
    #
    # @param [Object] default A default value to use if the option value is undefined
    # @yield [] Provide a default with a block instead of a parameter
    # @return [Object] If None, default, otherwise the value
    def get_or_else *default
      if empty?
        if block_given?
          yield
        else
          default.first
        end
      else
        get
      end
    end

    # Return this `Option` if non-empty, otherwise return the result of evaluating the default
    # @example
    #  Option(nil).or_else { "foo" } == Some("foo")
    #  Option("foo").or_else { "bar" } == Some("foo")
    # @return [Option<Object>]
    def or_else *default
      if empty?
        res = if block_given?
          yield
        else
          default.first
        end
        if res.is_a?(Option)
          res
        else
          ::Lidarr::Option(res)
        end
      else
        self
      end
    end

    # Return true if non-empty and predicate is true for the value
    # @example
    #  Option("foo").exists? ->(e) { e.to_s == "foo" } == true
    #  Option(nil).exists? ->(e) { e.to_s == "foo" } == false
    # @return [Boolean] test passed
    def exists? &predicate
      !empty? && predicate.call(get)
    end

    # Apply the block specified to the value if non-empty
    # @example
    #  Option("foo").each ->(e) { puts(e.to_s) }
    # @return [NilClass]
    def each block
      if self.defined?
        block.call(get)
      end
      nil
    end

    # If the option value is defined, apply the specified block to that value
    #
    # @example
    #  Option("15").map{|i| i.to_i}.get == 15
    #
    # @yieldparam [Object] block The current value
    # @yieldreturn [Object] The new value
    # @return [Option<Object>] Optional value
    def map &block
      if empty?
        None.new
      else
        Some.new(block.call(get))
      end
    end

    # Same as map, but flatten the results
    #
    # This is useful when operating on an object that will return an `Option`.
    #
    # @example
    #   Option(15).flat_map {|i| Option(i).filter{|i2| i2 > 0}} == Some(15)
    #
    # @see #map
    # @return [Option<Object>] Optional value
    def flat_map &block
      if empty?
        None.new
      else
        res = block.call(get)
        if res.is_a?(Some)
          res
        else
          Some.new(res)
        end
      end
    end

    # Convert to `None` if predicate fails
    #
    # Returns this option if it is non-empty *and* applying the predicate to this options returns
    # true. Otherwise return `None`.
    #
    # @yieldparam [Object] predicate The current value
    # @yieldreturn [Boolean] result of testing value
    # @return [Option<Object>] `None` if predicate fails, or already `None`
    def filter &predicate
      if empty? || predicate.call(get)
        self
      else
        None.new
      end
    end

    # Inverse of `filter` operation.
    #
    # Returns this option if it is non-empty *and* applying the predicate to this option returns
    # false. Otherwise return `None`.
    #
    # @see #filter
    # @return [Option<Object>]
    def filter_not &predicate
      if empty? || !predicate.call(get)
        self
      else
        None.new
      end
    end
  end

  # Represents a missing value
  class None < Option
    # Always true for `None`
    # @see Option#empty?
    def empty?
      true
    end

    # Always raises a NameError
    # @raise [NameError]
    def get
      raise NameError.new("None.get")
    end

    def eql? other
      self.class.equal?(other.class)
    end
    alias_method :==, :eql?
  end

  # Represents a present value
  #
  # A number of equality and comparison methods are implemented so that `Some` values are compared
  # using the value of `x`.
  class Some < Option
    def initialize value
      @x = value
    end

    def empty?
      false
    end

    def get
      x
    end

    def eql? other
      self.class.equal?(other.class) && x.eql?(other.x)
    end
    alias_method :==, :eql?
    def hash
      x.hash
    end

    def <=>(other)
      instance_of?(other.class) ?
        (x <=> other.x) : nil
    end

    protected

    attr_reader :x
  end
end # end module Lidarr
