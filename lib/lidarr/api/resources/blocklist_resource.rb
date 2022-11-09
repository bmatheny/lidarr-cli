# frozen_string_literal: true

require_relative "resource"

module Lidarr
  module API
    class BlocklistResource < Resource
      def initialize
        super()
        resourcify "BlocklistResource"
      end
    end
  end
end
