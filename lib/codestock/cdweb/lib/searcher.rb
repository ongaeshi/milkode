# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/xx/xxxx

require 'codestock/cdweb/lib/query'
require 'codestock/cdweb/lib/grep'

module CodeStock
  class Searcher
    attr_reader :keyword
    attr_reader :total_records
    attr_reader :elapsed
    attr_reader :page
    
    def initialize(path, keyword, page)
      @keyword = keyword
      @query = Query2.new(@keyword)
      @page = page || 0
      fpaths = @query.fpaths
      fpaths << path unless path == ""
      @records, @total_records, @elapsed = Database.instance.search(@query.keywords, @query.packages, fpaths, @query.suffixs, page, limit)
      # @todo 厳密に検索するには、さらに検索結果から先頭からのパスではないものを除外する
    end

    def page_range
      pageStart = page * limit
      (@total_records.zero? ? 0 : pageStart + 1)..(pageStart + @records.size)
    end

    def html_contents
      str = ""
      @records.each do |record|
        str += result_record(record, @query.keywords, 3)
      end
      str
    end
    
    def html_pagination
      return "" if @query.empty?
      return "" if @total_records < limit

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
      if @query.keywords.size == 0
        100
      else
        20
      end
    end
    
    def result_record(record, patterns, nth=1)
      if (patterns.size > 0)
        <<EOS
    <dt class='result-record'><a href='#{"/home/" + Rack::Utils::escape_html(record.shortpath)}'>#{record.shortpath}</a></dt>
    <dd>
      <pre class='lines'>
#{result_record_match_line(record, patterns, nth)}
      </pre>
    </dd>
EOS
      else
        <<EOS
    <dt class='result-record'><a href='#{"/home/" + Rack::Utils::escape_html(record.shortpath)}'>#{record.shortpath}</a></dt>
EOS
      end
    end
    
    def result_record_match_line(record, patterns, nth)
      str = ""
      
      grep = Grep.new(record.content)
      lines = grep.match_lines_or(patterns)

      unless (lines.empty?)
        index = lines[0].index
        
        (index - nth..index + nth).each do |i|
          if (0 <= i && i < grep.content.size)
            match_datas = (i == index) ? lines[0].match_datas : []
            str << line(i + 1, grep.content[i], match_datas) + "\n"
          end
        end
      end

      str
    end

    def line(lineno, line, match_datas)
      sprintf("%5d: %s", lineno, match_strong(Rack::Utils::escape_html(line), match_datas))
    end

    def match_strong(line, match_datas)
      match_datas.each do |m|
        line = line.split(m[0]).join('<strong>' + m[0] + '</strong>') unless (m.nil?)
      end
      
      line
    end

    def pagination_link(page, label)
      href = "?keyword=#{Rack::Utils::escape_html(keyword)}&page=#{page}"
      pagination_span("<a href='#{href}'>#{label}</a>")
    end

    def pagination_span(content)
      "<span class='pagination-link'>#{content}</span>\n"
    end

  end
end



