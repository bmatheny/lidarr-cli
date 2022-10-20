# frozen_string_literal: true

require_relative "output_plain"
require_relative "../logging"

module Lidarr
  module CLI
    module Output
      extend self

      def print_results format, results
        if format == "plain"
          Plain.print_results results
        else
          Lidarr.logger.fatal "No support for format #{format}"
        end
      end
    end # end module Output
  end # end module CLI
end # end module Lidarr
