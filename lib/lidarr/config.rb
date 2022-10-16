# frozen_string_literal: true

require_relative "../lidarr"
require_relative "option"
require "yaml"

module Lidarr
  module Config
    class << self
      include Lidarr::Mixins

      def options_from_configs
        files = get_files
        options = Lidarr::Options.new
        files.each do |file|
          if File.exist?(file)
            puts "Trying file #{file}"
            options.merge(from_config(file))
          end
        end
        options
      end # end options_from_config

      def from_config file
        opts = Lidarr::Options.new
        return opts unless File.exist?(file)
        yml = get_yml file
        if yml.key?(:api_key)
          opts.api_key = yml[:api_key]
        end
        if yml.key?(:headers)
          yml[:headers].each do |header|
            opts.header_set header
          end
        end
        if yml.key?(:url)
          opts.url = yml[:url]
        end
        if yml.key?(:verbose)
          opts.verbose = yml[:verbose]
        end
        opts
      end

      def get_files
        files = ["/etc/lidarr-cli.yml", File.expand_path("~/.config/lidarr/cli.yml")]
        if ENV.key?("LIDARR_CONFIG")
          files << ENV["LIDARR_CONFIG"]
        end
        files
      end

      def get_yml file
        yml = YAML.safe_load(File.read(file))
        require_that yml.is_a?(Hash), "Invalid YAML found"
        symbolize_hash(yml, downcase: true)
      end
    end # end class << self
  end # end module Config
end # end module Lidarr
