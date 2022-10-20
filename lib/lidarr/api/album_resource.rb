# frozen_string_literal: true

require_relative "resource"

module Lidarr
  module API
    # I have no clue what the difference between an Album and an AlbumResource is in lidarr speak,
    # not sure why they have both but they do and neither is a complete superset of the other.
    class AlbumModel < Resource
      def initialize
        super()
        ["id",
          "artistMetadataId",
          "foreignAlbumId",
          "oldForeignAlbumIds",
          "title",
          "overview",
          "disambiguation",
          "releaseDate",
          "images",
          "links",
          "genres",
          "albumType",
          "secondaryTypes",
          "ratings",
          "cleanTitle",
          "profileId",
          "monitored",
          "anyReleaseOk",
          "lastInfoSync",
          "added",
          "addOptions",
          "artistMetadata",
          "albumReleases",
          "artist"].each do |item|
          name, type = item
          register_property name, type
        end
      end
    end

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
