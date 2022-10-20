# frozen_string_literal: true

require_relative "resource"

module Lidarr
  module API
    class AlbumResource < Resource
      def initialize
        super()
        ["id",
          "title",
          "disambiguation",
          "overview",
          "artistId",
          "foreignAlbumId",
          "monitored",
          "anyReleaseOk",
          "profileId",
          "duration",
          "albumType",
          "secondaryTypes",
          "mediumCount",
          "ratings", # /components/schemas/Ratings
          "releaseDate", # date-time
          "releases", # Array</components/schemas/AlbumReleaseResource>
          "genres",
          "media", # Array</components/schemas/MediumResource>
          ["artist", ArtistResource], # /components/schemas/ArtistResource
          "images", # Array</components/schemas/MediaCover>
          "links", # Array</components/schemas/Links>
          ["statistics", AlbumStatisticsResource], # /components/schemas/AlbumStatisticsResource
          "addOptions", # /components/schemas/AddAlbumOptions
          "remoteCover",
          "grabbed"].each do |item|
          name, type = item
          register_property name, type
        end
      end
    end # class AlbumResource
  end
end
