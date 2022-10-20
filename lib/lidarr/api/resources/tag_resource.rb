# frozen_string_literal: true

require_relative "resource"

module Lidarr
  module API
    class TagResource < Resource
      def initialize
        super()
        register_property "id"
        register_property "label"
      end
    end

    class TagDetailsResource < TagResource
      def initialize
        super()
        register_property "artistIds"
        register_property "delayProfileIds"
        register_property "importListIds"
        register_property "notificationIds"
        register_property "restrictionids"
        register_property "indexerIds"
      end
    end
  end
end
