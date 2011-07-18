# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/18

require 'codestock/cdweb/lib/query'
require 'codestock/cdweb/lib/grep'
require 'codestock/cdweb/lib/mkurl'

module CodeStock
  class SearchContents
    attr_reader :total_records
    attr_reader :elapsed
    attr_reader :page
    
    DISP_NUM = 20              # 1ページの表示数
    LIMIT_NUM = 50             # 最大検索ファイル数
    NTH = 3                    # 表示範囲

    def initialize(path, params, query)
      @params = params
      @q = query
      @page = params[:page].to_i || 0
      @offset = params[:offset].to_i
      fpaths = @q.fpaths
      fpaths << path unless path == ""
      @records, @total_records, @elapsed = Database.instance.search2(@q.keywords, @q.packages, fpaths, @q.suffixs, @offset, LIMIT_NUM)
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
      @match_records.map {|match_record| result_match_record(match_record)}.join
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

    MatchRecord = Struct.new(:record, :match_line)

    def grep_contents
      @match_records = []
      @next_index = @records.size
      
      @records.each_with_index do |record, index|
        grep = Grep.new(record.content)
        match_line = grep.one_match_and2(@q.keywords)
        @match_records << MatchRecord.new(record, match_line) if match_line

        if @match_records.size > DISP_NUM
          @next_index = index + 1
          break
        end
      end
    end

    def result_match_record(match_record)
      record = match_record.record
      content_a = record.content.split("\n")
      match_line = match_record.match_line

      first_index = match_line.index - NTH
      first_index = 0 if first_index < 0

      last_index = match_line.index + NTH
      last_index = content_a.size-1 if last_index >= content_a.size

      coderay = CodeRayWrapper.new(record.content, record.shortpath, [match_line])
      coderay.set_range(first_index..last_index)

      <<EOS
    <dt class='result-record'><a href='#{"/home/" + record_link(record) + "##{coderay.line_number_start}"}'>#{record.shortpath}</a></dt>
    <dd>
#{coderay.to_html}
    </dd>
EOS
    end

    def pagination_link(offset, label)
      tmpp = @params
      tmpp[:offset] = offset.to_s
      href = Mkurl.new("", tmpp).inherit_query_shead_offset
      pagination_span("<a href='#{href}'>#{label}</a>")
    end

    def pagination_span(content)
      "<span class='pagination-link'>#{content}</span>\n"
    end

    def record_link(record)     # 
      Mkurl.new(record.shortpath, @params).inherit_query_shead
    end

  end
end



