# frozen_string_literal: true

require_relative "resource"

module Lidarr
  module API
    # I have no clue what the difference between an Album and an AlbumResource is in lidarr speak,
    # not sure why they have both but they do and neither is a complete superset of the other.
    class AlbumModel < Resource
      def initialize
        super()
        resourcify "Album"
      end
    end

    class AlbumResource < Resource
      def initialize
        super()
        resourcify "AlbumResource"
      end

      # Note to myself for later
      def tmp1
        ["ratings", # /components/schemas/Ratings
          "releaseDate", # date-time
          "releases", # Array</components/schemas/AlbumReleaseResource>
          "media", # Array</components/schemas/MediumResource>
          "images", # Array</components/schemas/MediaCover>
          "links", # Array</components/schemas/Links>
          "addOptions"] # /components/schemas/AddAlbumOptions
      end
    end # class AlbumResource
  end
end
