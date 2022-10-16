# frozen_string_literal: true

require "lidarr"
require "thor"

module Lidarr
  class CLI < Thor
    desc "version", "prints lidarr CLI version"
    def version
      puts Lidarr::VERSION
    end
  end
end
