# frozen_string_literal: true

require_relative "../lidarr"
require_relative "option"
require_relative "opt/conv"
require "yaml"

module Lidarr
  module Config
    extend self
    include Lidarr::Mixins

    def options_from_configs
      files = get_files
      options = Lidarr::Options.new
      files.each do |file|
        if File.exist?(file)
          hash = get_yml(file)
          opts = Lidarr::Opt.hash_to_options(hash)
          options.merge(opts)
        end
      end
      options
    end # end options_from_config

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
  end # end module Config
end # end module Lidarr
