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
require 'milkode/database/document_record'

module Milkode
  class SearchFiles
    attr_reader :total_records

    DISP_NUM = 100              # 1ページの表示数
    
    def initialize(path, params, query, suburl)
      @path    = path
      @params  = params
      @q       = query
      @suburl  = suburl
      @homeurl = @suburl + "/home/"
      
      @offset = params[:offset].to_i

      if (@q.fpaths.include?("*"))
        @records, @total_records = Database.instance.selectAll(@offset, DISP_NUM)
      else
        @records, @total_records = Database.instance.search(@q.keywords, @q.multi_match_keywords, @q.packages, path, @q.fpaths, @q.suffixs, @q.fpath_or_packages, @offset, DISP_NUM)
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
      @records.map {|record| result_record(DocumentRecord.new(record))}.join
    end
    
    def html_pagination
      return "" if @q.empty?
      return "" if @total_records < DISP_NUM
      
      return <<EOF
<div class='pagination pagination-centered'>
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
      "<ul><li>#{content}</li></ul>\n"
    end

    def result_record(record)
      filename = Util.relative_path(record.shortpath, @path).to_s
      filename = Util.highlight_keywords(filename, @q.fpaths + @q.fpath_or_packages, 'highlight-filename')

      <<EOS
    <dt class='result-file'>#{file_or_dirimg(true, @suburl)}<a href='#{@homeurl + record_link(record)}'>#{filename}</a></dt>
EOS
    end

    def record_link(record)
      Mkurl.new(record.shortpath, @params).inherit_query_shead
    end

  end
end



