# frozen_string_literal: true

require_relative "resource"

module Lidarr
  module API
    class ArtistResource < Resource
      def initialize
        super()
        ["id",
          "artistMetadataId",
          "status", # ArtistStatusType
          "ended",
          "artistName",
          "foreignArtistId",
          "mbId",
          "tadbId",
          "discogsId",
          "allMusicId",
          "overview",
          "artistType",
          "disambiguation",
          "links", # Array<Links>
          "nextAlbum", # Album
          "lastAlbum", # Album
          "images", # Array<MediaCover>
          "members", # Array<Member>
          "remotePoster",
          "path",
          "qualityProfileId",
          "metadataProfileId",
          "monitored",
          "monitorNewItems", # NewItemMonitorTypes
          "rootFolderPath",
          "genres",
          "cleanName",
          "sortName",
          "tags",
          "added", # date-time
          "addOptions", # AddArtistOptions
          "ratings", # Ratings
          ["statistics", ArtistStatisticsResource]].each do |item|
          name, type = item
          register_property name, type
        end
      end
    end
  end # end module API
end
