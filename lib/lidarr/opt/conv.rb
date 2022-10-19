# frozen_string_literal: true

require_relative "../option"
require_relative "../mixins"

module Lidarr
  module Opt
    extend self

    OptionMap = Struct.new("OptionMap", :api_key, :headers, :secure, :url, :verbose)

    def thor_to_options options
      Lidarr::Mixins.require_type(options, Hash)
      option_map = OptionMap.new("api_key", "header", "secure", "url", "verbose")
      map_to_options options, option_map
    end

    def hash_to_options hsh
      Lidarr::Mixins.require_type(hsh, Hash)
      option_map = OptionMap.new(:api_key, :headers, :secure, :url, :verbose)
      map_to_options hsh, option_map
    end

    def env_to_options env
      Lidarr::Mixins.require_type(env, Hash)
      option_map = OptionMap.new("LIDARR_API_KEY", "LIDARR_HEADERS", "LIDARR_URL", "LIDARR_VERBOSE", "LIDARR_SECURE")
      opts = map_to_options env, option_map
      env.select { |k, _| k.to_s.match?(/^LIDARR_HEADERS_/) }.each do |_, header|
        opts.header_set header
      end
      opts
    end

    def map_to_options map, option_map
      Lidarr::Mixins.require_type(map, Hash)
      Lidarr::Mixins.require_type(option_map, OptionMap)

      opts = Lidarr::Options.new
      apikey_key = option_map.api_key
      header_key = option_map.headers
      secure_key = option_map.secure
      url_key = option_map.url
      verbose_key = option_map.verbose

      if map.key?(apikey_key)
        opts.api_key = map[apikey_key]
      end
      if map.key?(header_key)
        map[header_key].each do |header|
          opts.header_set header
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
  end # end module Opt
end
