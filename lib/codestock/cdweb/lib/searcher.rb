# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/xx/xxxx

require 'codestock/cdweb/lib/query'
require 'codestock/cdweb/lib/grep'
require 'codestock/cdweb/lib/mkurl'

module CodeStock
  class Searcher
    attr_reader :total_records
    attr_reader :elapsed
    attr_reader :page
    
    def initialize(path, params)
      @params = params
      @q = Query.new(params[:query])
      @page = params[:page].to_i || 0
      @offset = params[:offset].to_i
      fpaths = @q.fpaths
      fpaths << path unless path == ""
      @records, @total_records, @elapsed = Database.instance.search2(@q.keywords, @q.packages, fpaths, @q.suffixs, @offset)
      # @todo 厳密に検索するには、さらに検索結果から先頭からのパスではないものを除外する
    end

    def query
      @q.query_string
    end

    def page_range
      #       pageStart = page * limit
      #       (@total_records.zero? ? 0 : pageStart + 1)..(pageStart + @records.size)
      @offset..1000
      # @offset..@grep_endindex
    end

    def html_contents
      result = []
      @records.each_with_index do |record, index|
        r = result_record(record, @q.keywords, 3)
        unless (r == "")
          result << r
          if result.size >= limit
            @grep_end_index = index
            break
          end
        end
      end
      result.join
    end
    
    def html_pagination
      return "" if @q.empty?
      return "" if @total_records < limit

      last_page = (@total_records / limit.to_f).ceil      

      return <<EOF
<div class='pagination'>
#{pagination_link(@offset + @grep_end_index + 1, "next >>") if page < (last_page - 1)}
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

    def offset_link(offset, label)
    end

    def pagination_span(content)
      "<span class='pagination-link'>#{content}</span>\n"
    end

    # 1ページに表示する最大レコードを計算
    def limit
      if @q.keywords.size == 0
        100
      else
        20
      end
    end
    
    def result_record(record, patterns, nth=1)
      if (patterns.size > 0)
        result_record_grep(record, patterns, nth)
      else
        <<EOS
    <dt class='result-record'><a href='#{"/home/" + record_link(record)}'>#{record.shortpath}</a></dt>
EOS
      end
    end

    def record_link(record)
      Mkurl.new(record.shortpath, @params).inherit_query_shead
    end

    def result_record_grep(record, patterns, nth)
      grep = Grep.new(record.content)
      match_lines = grep.one_match_and(patterns)
      return "" if (match_lines.empty?)

      first_index = match_lines[0].index - nth
      first_index = 0 if first_index < 0

      last_index = match_lines[0].index + nth
      last_index = grep.content.size-1 if last_index >= grep.content.size

      coderay = CodeRayWrapper.new(record.content, record.shortpath, match_lines)
      coderay.set_range(first_index..last_index)

      <<EOS
    <dt class='result-record'><a href='#{"/home/" + record_link(record) + "##{coderay.line_number_start}"}'>#{record.shortpath}</a></dt>
    <dd>
#{coderay.to_html}
    </dd>
EOS
    end
    
  end
end



