# frozen_string_literal: true

require "lidarr"

module Lidarr
  class Options
    include Lidarr::Mixins

    def initialize
      @opts = {}
    end

    private

    attr_accessor :opts
  end
end
