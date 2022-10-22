# frozen_string_literal: true

module Lidarr
  module CLI
    module Views
      module TagDetailsView
        def fn_clean_artists
          Array(artistIds).join("|")
        end

        def fn_clean_indexers
          Array(indexerIds).join("|")
        end
      end
    end
  end
end
