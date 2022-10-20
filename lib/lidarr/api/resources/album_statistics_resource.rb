# frozen_string_literal: true

require_relative "resource"

module Lidarr
  module API
    class AlbumStatisticsResource < Resource
      def initialize
        super()
        register_property "trackFileCount"
        register_property "trackCount"
        register_property "totalTrackCount"
        register_property "sizeOnDisk"
        register_property "percentOfTracks"
      end
    end
  end # end API module
end
