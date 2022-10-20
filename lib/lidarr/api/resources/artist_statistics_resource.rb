# frozen_string_literal: true

module Lidarr
  module API
    class ArtistStatisticsResource < Resource
      def initialize
        super()
        register_property "albumCount"
        register_property "trackFileCount"
        register_property "trackCount"
        register_property "totalTrackCount"
        register_property "sizeOnDisk"
        register_property "percentOfTracks"
      end
    end
  end # end API module
end
