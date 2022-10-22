# frozen_string_literal: true

module Lidarr
  module API
    class PagingRequest
      # ?page=1&pageSize=20&sortDirection=descending&sortKey=releaseDate&monitored=true
      # page 0 == page 1, pageSize limit 200 in web UI
      # monitored is not documented
      attr_accessor :page, :page_size, :sort_key, :sort_direction, :filters

      def initialize(page: nil, page_size: nil, sort_key: nil, sort_direction: nil, filters: nil)
        # sortDirection: default, ascending, descending
        # sortKey: artistName, albumTitle, albumTitle, releaseDate
        @page = page
        @page_size = page_size
        @sort_key = sort_key
        @sort_direction = sort_direction
        @filters = filters
      end

      def get_query
        q = {}
        q[:page] = @page unless @page.nil?
        q[:pageSize] = @page_size unless @page_size.nil?
        q[:sortKey] = @sort_key unless @sort_key.nil?
        q[:sortDirection] = @sort_direction unless @sort_direction.nil?
        q[:filters] = @filters unless @filters.nil?
        q
      end

      def to_s
        opts = []
        opts << "page=#{page}" unless page.nil?
        opts << "pageSize=#{page_size}" unless page_size.nil?
        opts << "sortKey=#{sort_key}" unless sort_key.nil?
        opts << "sortDirection=#{sort_direction}" unless sort_direction.nil?
        opts << "filters=#{filters}" unless filters.nil?
        opts_string = opts.join(", ")
        opts_string = "default" if opts_string.empty?
        "PagingRequest(#{opts_string})"
      end
    end # end PagingRequest

    class PagingResource < PagingRequest
      attr_accessor :total_records, :records

      def initialize(page: nil, page_size: nil, sort_key: nil, sort_direction: nil, filters: nil, total_records: nil, records: nil)
        super(page: page, page_size: page_size, sort_key: sort_key, sort_direction: sort_direction, filters: filters)
        @total_records = total_records
        @records = records
      end

      def to_h
        {
          page: page,
          pageSize: page_size,
          sortKey: sort_key,
          sortDirection: sort_direction,
          filters: filters,
          totalRecords: total_records
        }
      end

      def self.from_response(response, &block)
        res = if response.is_a?(Hash)
          response
        else
          {}
        end
        PagingResource.new(
          page: res.fetch("page", nil),
          page_size: res.fetch("pageSize", nil),
          sort_key: res.fetch("sortKey", nil),
          sort_direction: res.fetch("sortDirection", nil),
          filters: res.fetch("filters", nil),
          total_records: res.fetch("totalRecords", nil),
          records: res.fetch("records", []).map { |rr| block.call(rr) }
        )
      end
    end # end AlbumResourcePaginationResource
  end
end
