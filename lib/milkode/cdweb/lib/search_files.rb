# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/18

require 'milkode/cdweb/lib/query'
require 'milkode/cdweb/lib/mkurl'
require 'milkode/cdweb/lib/command'
require 'milkode/common/util'

module Milkode
  class SearchFiles
    attr_reader :total_records

    DISP_NUM = 100              # 1ページの表示数
    
    def initialize(path, params, query)
      @path = path
      @params = params
      @q = query
      
      @offset = params[:offset].to_i

      if (@q.fpaths.include?("*"))
        @records, @total_records = Database.instance.selectAll(@offset, DISP_NUM)
      else
        @records, @total_records = Database.instance.search(@q.keywords, @q.packages, path, @q.fpaths, @q.suffixs, @offset, DISP_NUM)
      end
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

    def match_num
      @records.size
    end

    private

    def pagination_link(offset, label)
      tmpp = @params
      tmpp[:offset] = offset.to_s
      href = Mkurl.new("", tmpp).inherit_query_shead_offset
      pagination_span("<a href='#{href}' rel='next'>#{label}</a>")
    end

    def pagination_span(content)
      "<span class='pagination-link'>#{content}</span>\n"
    end

    def result_record(record)
      <<EOS
    <dt class='result-file'>#{file_or_dirimg(true)}<a href='#{"/home/" + record_link(record)}'>#{Util::relative_path record.shortpath, @path}</a></dt>
EOS
    end

    def record_link(record)
      Mkurl.new(record.shortpath, @params).inherit_query_shead
    end

  end
end



