# frozen_string_literal: true

module Lidarr
  module API
    class AlbumResource
      SAFE_PROPERTIES = ["title", "artistId", "monitored", "profileId", "duration", "albumType", "releaseDate", "genres", "artist#ArtistResource", "statistics#AlbumStatisticsResource", "grabbed"]
      attr_accessor :id, :title, :monitored, :artist, :albumType, :releaseDate, :statistics

      def initialize id = nil
        @id = id
      end

      def to_s
        vals = []
        SAFE_PROPERTIES.map { |k| k.split("#", 2).first }.map do |prop|
          if AlbumResource.has_setter(self, prop)
            [prop, send(prop.to_sym)]
          else
            [prop, nil]
          end
        end.reject { |(_, v)| v.nil? }.each do |(k, v)|
          vals << "@#{k}=\"#{v}\""
        end
        "AlbumResource(@id=\"#{id}\", #{vals.join(", ")})"
      end

      def self.from_record record
        safe_properties = SAFE_PROPERTIES
          .map { |k| k.split("#", 2) }
          .each_with_object({}) do |item, hash|
            hash.store(item[0], item.fetch(1, nil))
          end
        r = AlbumResource.new(record["id"])
        record.select { |k, v| safe_properties.include?(k) }.each do |k, v|
          key, resource = k, safe_properties.fetch(k, nil)
          next unless has_setter(r, key)
          value = if resource.nil?
            v
          else
            Lidarr::API.const_get(resource).from_record(v)
          end
          r.send(setter_sym(key), value)
        end
        r
      end

      def self.has_setter resource, name
        arg_name = setter_sym(name)
        resource.respond_to?(arg_name) && resource.method(arg_name).arity == 1
      end

      def self.setter_sym name
        "#{name}=".to_sym
      end
    end # class AlbumResource
  end
end
