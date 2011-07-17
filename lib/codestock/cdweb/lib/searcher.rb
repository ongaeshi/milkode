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
      fpaths = @q.fpaths
      fpaths << path unless path == ""
      @records, @total_records, @elapsed = Database.instance.search(@q.keywords, @q.packages, fpaths, @q.suffixs, page, limit)
      # @todo 厳密に検索するには、さらに検索結果から先頭からのパスではないものを除外する
    end

    def query
      @q.query_string
    end

    def page_range
      pageStart = page * limit
      (@total_records.zero? ? 0 : pageStart + 1)..(pageStart + @records.size)
    end

    def html_contents
      str = ""
      @records.each do |record|
        str += result_record(record, @q.keywords, 3)
      end
      str
    end
    
    def html_pagination
      return "" if @q.empty?
      return "" if @total_records < limit

      last_page = (@total_records / limit.to_f).ceil      

      return <<EOF
<div class='pagination'>
#{pagination_link(page + 1, "next >>") if page < (last_page - 1)}
</div>
EOF

      # -- obsolate
      str = ""

      last_page = (@total_records / limit.to_f).ceil
      str += "<div class='pagination'>\n"
      if page > 0
        str += pagination_link(page - 1, "<<")
      end
      last_page.times do |i|
        if i == page
          str += pagination_span(i)
        else
          str += pagination_link(i, i)
        end
      end
      if page < (last_page - 1)
        str += pagination_link(page + 1, ">>")
      end
      str += "</div>\n"

      str
    end

    private

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
      match_lines = grep.match_lines_and(patterns)
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
    
    def pagination_link(page, label)
      tmpp = @params
      tmpp[:page] = page.to_s
      href = Mkurl.new("", tmpp).inherit_query_shead_page
      pagination_span("<a href='#{href}'>#{label}</a>")
    end

    def pagination_span(content)
      "<span class='pagination-link'>#{content}</span>\n"
    end

  end
end



