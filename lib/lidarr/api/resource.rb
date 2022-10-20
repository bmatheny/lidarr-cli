# frozen_string_literal: true

module Lidarr
  module API
    class Resource
      def initialize
        @_names = {}
      end

      def populate record
        @_names.each do |key, type|
          next unless record.key?(key)
          val = record[key]
          val = Lidarr::API.const_get(type).new.populate(record) unless type.nil?
          send("#{key}=".to_sym, val)
        end
        self
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
    end
  end
end
