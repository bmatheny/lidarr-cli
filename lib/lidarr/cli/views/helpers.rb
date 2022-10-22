# frozen_string_literal: true

module Lidarr
  module CLI
    module Views
      module ViewHelpers
        def truncate string, max
          if string.nil?
            ""
          elsif string.length > max
            "#{string[0...max]}..."
          else
            string
          end
        end
      end # module Helpers
    end
  end
end
