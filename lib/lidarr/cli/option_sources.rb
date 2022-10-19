# frozen_string_literal: true

require_relative "../mixins"
require_relative "../options"

module Lidarr
  module CLI
    module OptionSources
      extend self

      # Value is {:thor => name, :file => name, :env => name} if you want to override what the name
      # will be for one of those sources. If you want to add a new variable that is respected from
      # CLI, ENV, config files, and used by Lidarr::Options, do the following:
      #   1. Add new symbol:replacement setting to OPTION_MAP below
      #   2. Add new methods in Lidarr::Options
      #   3. Update map_to_options below
      OPTION_MAP = {
        api_key: nil,
        headers: {thor: "header"}.freeze,
        secure: nil,
        url: nil,
        verbose: nil
      }.freeze

      def env_to_options env
        Lidarr::Mixins.require_type(env, Hash)
        opts = map_to_options env, get_option_map(:env)
        env.select { |k, _| k.to_s.match?(/^LIDARR_HEADERS_/) }.each do |_, header|
          opts.headers = header
        end
        opts
      end

      def files_to_options files
        Lidarr::Mixins.require_type(files, Array)
        options = Lidarr::Options.new
        files.each do |file|
          opts = file_to_options(file)
          options.merge(opts) unless opts.nil?
        end
        options
      end

      def file_to_options file
        Lidarr::Mixins.require_type(file, String)
        if File.exist?(file)
          hash = get_yaml(file)
          map_to_options hash, get_option_map(:file)
        end
      end

      def thor_to_options options
        Lidarr::Mixins.require_type(options, Hash)
        map_to_options options, get_option_map(:thor)
      end

      private_class_method def get_option_map(type)
        [:env, :file, :thor].include?(type) || abort("Invalid type #{type} specified")
        OPTION_MAP.each_with_object({}) do |(map_key, value), result|
          new_value = if !value.nil? && value.key?(type)
            value[type]
          elsif type == :env
            "LIDARR_#{map_key.to_s.upcase}"
          elsif type == :file
            map_key.to_sym
          elsif type == :thor
            map_key.to_s.downcase
          else
            abort "Invalid type #{type} found"
          end
          result[map_key] = new_value
          result
        end
      end

      private_class_method def map_to_options map, option_map
        Lidarr::Mixins.require_type(map, Hash)
        Lidarr::Mixins.require_type(option_map, Hash)

        opts = Lidarr::Options.new
        apikey_key = option_map[:api_key]
        header_key = option_map[:headers]
        secure_key = option_map[:secure]
        url_key = option_map[:url]
        verbose_key = option_map[:verbose]

        if map.key?(apikey_key)
          opts.api_key = map[apikey_key]
        end
        if map.key?(header_key)
          Lidarr::Mixins.require_type(map[header_key], Array)
          map[header_key].each do |header|
            opts.headers = header
          end
        end
        if map.key?(secure_key)
          opts.secure = map[secure_key]
        end
        if map.key?(url_key)
          opts.url = map[url_key]
        end
        if map.key?(verbose_key)
          opts.verbose = map[verbose_key]
        end
        opts
      end

      private_class_method def get_yaml file
        yaml = YAML.safe_load(File.read(file))
        Lidarr::Mixins.require_that(yaml.is_a?(Hash), "Invalid YAML found")
        Lidarr::Mixins.symbolize_hash(yaml, downcase: true)
      end
    end # end OptionSources module
  end
end
