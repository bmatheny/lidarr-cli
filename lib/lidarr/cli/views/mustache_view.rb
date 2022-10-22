# frozen_string_literal: true

require_relative "../../data"
require "mustache"

module Lidarr
  module CLI
    module Views
      module NoOp
      end

      class MustacheView < Mustache
        def self.template_path
          Lidarr::Data.templates
        end
      end # class MustacheView
    end
  end
end
