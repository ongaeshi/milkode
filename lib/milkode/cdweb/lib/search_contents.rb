# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/18

require 'milkode/cdweb/lib/query'
require 'milkode/cdweb/lib/grep'
require 'milkode/cdweb/lib/mkurl'
require 'milkode/common/util'

module Milkode
  class SearchContents
    attr_reader :total_records
    attr_reader :elapsed
    attr_reader :page
    
    DISP_NUM = 20              # 1ページの表示数
    LIMIT_NUM = 50             # 最大検索ファイル数
    NTH = 3                    # 表示範囲
    COL_LIMIT = 200            # 1行の桁制限
    
#     DISP_NUM = 1000              # 1ページの表示数
#     LIMIT_NUM = 1000             # 最大検索ファイル数
#     NTH = 3                      # 表示範囲
#     COL_LIMIT = 200              # 1行の桁制限
    
    def initialize(path, params, query)
      @path = path
      @params = params
      @q = query
      @page = params[:page].to_i || 0
      @offset = params[:offset].to_i
      fpaths = @q.fpaths
      fpaths << path + "/" unless path == ""
      @records, @total_records, @elapsed = Database.instance.search(@q.keywords, @q.packages, fpaths, @q.suffixs, @offset, LIMIT_NUM)
      grep_contents
    end

    def query
      @q.query_string
    end

    def next_offset
      @offset + @next_index
    end

    def data_range
      @offset..(next_offset - 1)
    end

    def html_contents
      @match_records.map {|match_record| result_match_record(match_record)}
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
      @match_records.size
    end

    private

    MatchRecord = Struct.new(:record, :match_line)

    def grep_contents
      @match_records = []
      @next_index = @records.size
      
      @records.each_with_index do |record, index|
        if (Util::larger_than_oneline(record.content))
          grep = Grep.new(record.content)
          match_line = grep.one_match_and(@q.keywords)
          @match_records << MatchRecord.new(record, match_line) if match_line
        else
          @match_records << MatchRecord.new(record, Grep::MatchLineResult.new(0, nil))
        end

        if @match_records.size >= DISP_NUM
          @next_index = index + 1
          break
        end
      end
    end

    def result_match_record(match_record)
      record = match_record.record
      match_line = match_record.match_line

      first_index = match_line.index - NTH
      last_index = match_line.index + NTH

      coderay = CodeRayWrapper.new(record.content, record.shortpath, [match_line])
      coderay.col_limit(COL_LIMIT)
      coderay.set_range(first_index..last_index)

      <<EOS
    <dt class='result-record'><a href='#{"/home/" + record_link(record) + "##{coderay.line_number_start}"}'>#{Util::relative_path record.shortpath, @path}</a></dt>
    <dd>
#{coderay.to_html}
    </dd>
EOS
      href = "/home/" + record_link(record) + "#" + coderay.line_number_start.to_s
      content = Util::relative_path record.shortpath, @path
      
      {:href => href, :content => content, :coderay => coderay.to_html}
    end

    def pagination_link(offset, label)
      tmpp = @params
      tmpp[:offset] = offset.to_s
      href = Mkurl.new("", tmpp).inherit_query_shead_offset
      pagination_span("<a href='#{href}' rel='next'>#{label}</a>")
    end

    def pagination_span(content)
      "<span class='pagination-link'>#{content}</span>\n"
    end

    def record_link(record)     # 
      Mkurl.new(record.shortpath, @params).inherit_query_shead
    end

  end
end



