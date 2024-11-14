# frozen_string_literal: true

module Lidarr
  module API
    class Resource
      def initialize
        @_names = {}
      end

      def self.from_record record
        const_get(name).new.populate(record)
      end

      def populate record
        @_names.each do |key, type|
          next unless (record.key?(key) and not record[key].nil?)
          val = record[key]
          val = type.new.populate(record[key]) unless type.nil?
          send("#{key}=".to_sym, val)
        end
        self
      end

      def to_h
        o = {}
        @_names.each do |key, type|
          val = send(key.to_sym)
          if type && val.respond_to?(:to_h)
            val = val.to_h
          end
          o[key.to_sym] = val
        end
        o
      end

      def to_s
        values = @_names.map do |key, _|
          "@#{key}=\"#{send(key.to_sym)}\""
        end.join(", ")
        "#{self.class.to_s.split("::").last}(#{values})"
      end

      protected

      def register_property name, alt_type = nil
        @_names[name] = alt_type
        self.class.send(:define_method, "#{name}=".to_sym) do |value|
          instance_variable_set("@" + name.to_s, value)
        end
        self.class.send(:define_method, name.to_sym) do
          instance_variable_get("@" + name.to_s)
        end
      end

      def resourcify name
        props = JSON.parse(File.read(Data.schema))
          .fetch("components", {})
          .fetch("schemas", {})
          .fetch(name, {})
          .fetch("properties", {})
        props.each do |key, value|
          if block_given?
            yield(key, value)
          else
            type = if value.key?("$ref")
              resource = value["$ref"].split("/").last
              if Lidarr::API.const_defined?(resource)
                Lidarr::API.const_get(resource)
              else
                Lidarr.logger.debug "No such resource #{resource}"
                nil
              end
            end
            Lidarr.logger.trace "Resourcifying #{key}/#{type}"
            register_property key, type
          end
        end
      end
    end
  end
end
