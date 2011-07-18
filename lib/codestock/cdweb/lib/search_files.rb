# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/18

require 'codestock/cdweb/lib/query'
require 'codestock/cdweb/lib/mkurl'

module CodeStock
  class SearchFiles
    attr_reader :total_records
    attr_reader :elapsed

    DISP_NUM = 100              # 1ページの表示数
    
    def initialize(path, params, query)
      @params = params
      @q = query

      @offset = params[:offset].to_i
      fpaths = @q.fpaths
      fpaths << path unless path == ""
      @records, @total_records, @elapsed = Database.instance.search2(@q.keywords, @q.packages, fpaths, @q.suffixs, @offset, DISP_NUM)
    end

    def query
      @q.query_string
    end

    def next_offset
      @offset + @records.size
    end

    def data_range
      @offset..(next_offset - 1)
    end

    def html_contents
      @records.map {|record| result_record(record)}.join
    end
    
    def html_pagination
      return "" if @q.empty?
      return "" if next_offset >= @total_records
      
      return <<EOF
<div class='pagination'>
#{pagination_link(next_offset, "next >>")}
</div>
EOF
    end

    private

    def pagination_link(offset, label)
      tmpp = @params
      tmpp[:offset] = offset.to_s
      href = Mkurl.new("", tmpp).inherit_query_shead_offset
      pagination_span("<a href='#{href}'>#{label}</a>")
    end

    def pagination_span(content)
      "<span class='pagination-link'>#{content}</span>\n"
    end

    def result_record(record)
      <<EOS
    <dt class='result-record'><a href='#{"/home/" + record_link(record)}'>#{record.shortpath}</a></dt>
EOS
    end

    def record_link(record)
      Mkurl.new(record.shortpath, @params).inherit_query_shead
    end

  end
end



