# frozen_string_literal: true

module Lidarr
  module Data
    extend self

    def getdir
      File.expand_path(File.join(__dir__, "data"))
    end

    def schema
      File.join(getdir, "openapi.json")
    end

    def templates
      File.join(getdir, "templates")
    end

    def template file
      File.join(templates, file)
    end
  end
end
