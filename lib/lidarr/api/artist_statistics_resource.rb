# frozen_string_literal: true

module Lidarr
  module API
    class ArtistStatisticsResource
      SAFE_PROPERTIES = ["albumCount", "trackFileCount", "trackCount", "totalTrackCount", "sizeOnDisk", "percentOfTracks"]

      attr_accessor :albumCount, :trackFileCount, :trackCount, :totalTrackCount, :sizeOnDisk, :percentOfTracks

      def to_s
        res = SAFE_PROPERTIES.map do |attr|
          "#{attr}=\"#{send(attr.to_sym)}\""
        end.join(", ")
        "ArtistStatisticsResource(#{res})"
      end

      def self.from_record record
        r = ArtistStatisticsResource.new
        SAFE_PROPERTIES.each do |attr|
          r.send("#{attr}=", record.fetch(attr, 0))
        end
        r
      end
    end
  end # end API module
end
