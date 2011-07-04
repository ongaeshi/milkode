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
    
    def initialize(keyword)
      @keyword = keyword
      @query = Query2.new(@keyword)
      @records, @total_records, @elapsed = Database.instance.search(@query.keywords, @query.packages, @query.fpaths, @query.suffixs, calcPage, calcLimit)
    end

    def page_range
      # @todo
      0..20
    end

    def html_contents
      str = ""
      @records.each do |record|
        str += result_record(record, @query.keywords, 3)
      end
      str
    end
    
    def html_pagination
    end

    private

    # 1ページに表示する最大レコードを計算
    def calcLimit
      if @query.keywords.size == 0
        100
      else
        20
      end
    end
    
    # 現在ページを計算
    def calcPage
      0
#      (@request['page'] || 0).to_i
    end

    def result_record(record, patterns, nth=1)
      if (patterns.size > 0)
        <<EOS
    <dt class='result-record'><a href='#{"/::view/" + Rack::Utils::escape_html(record.shortpath)}'>#{record.shortpath}</a></dt>
    <dd>
      <pre class='lines'>
#{result_record_match_line(record, patterns, nth)}
      </pre>
    </dd>
EOS
      else
        <<EOS
    <dt class='result-record'><a href='#{"/::view/" + Rack::Utils::escape_html(record.shortpath)}'>#{record.shortpath}</a></dt>
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

  end
end



