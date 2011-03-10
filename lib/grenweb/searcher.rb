# -*- coding: utf-8 -*-
#
# @file 
# @brief  検索処理本体
# @author ongaeshi
# @date   2010/10/13

require 'rack'
require File.join(File.dirname(__FILE__), 'database')
require File.join(File.dirname(__FILE__), 'html_renderer')
require File.join(File.dirname(__FILE__), 'query')

module Grenweb
  class Searcher
    include Rack::Utils

    def initialize
    end
    
    def call(env)
      @request = Rack::Request.new(env)
      @query = Query.new(@request)

      @response = Rack::Response.new
      @response["Content-Type"] = "text/html; charset=UTF-8"

      @nth = 3                  # マッチした行の前後何行を表示するか

      @rendeler = HTMLRendeler.new(@request.script_name + '/..')

      if @request.post? or @request['query']
        post_request
      else
        search
      end
    end

    private

    def post_request
      query = @request['query'] || ''
      if query.empty?
        @request.path_info = "/"
      else
        @request.path_info = "/#{escape(query)}/"
      end
      @response.redirect(@request.url.split(/\?/, 2)[0])
      @response.to_a
    end

    def search
      render_header
      render_search_box
      render_search_result
      render_footer
      @response.to_a
    end

    def render_header
      @response.write @rendeler.header("gren : #{@query.escape_html}", "gren")
    end

    def render_search_box
      @response.write @rendeler.search_box(@query.escape_html)
    end

    def render_search_result
      if @query.empty?
        @response.write @rendeler.empty_summary
      else
        records, total_records, elapsed = Database.instance.search(@query.keywords, @query.packages, @query.fpaths, @query.suffixs, calcPage, calcLimit)
        render_search_summary(records, total_records, elapsed)
        records.each { |record| @response.write(@rendeler.result_record(record, @query.keywords, @nth)) }
        render_pagination(calcPage, total_records)
      end
    end

    def render_search_summary(records, total_records, elapsed)
      pageStart = calcPage * calcLimit
      @response.write @rendeler.search_summary(@query.query_string,
                                                  total_records,
                                                  (total_records.zero? ? 0 : pageStart + 1)..(pageStart + records.size),
                                                  elapsed)
    end

    def render_pagination(page, total_records)
      return if @query.empty?
      return if total_records < calcLimit

      last_page = (total_records / calcLimit.to_f).ceil
      @response.write("<div class='pagination'>\n")
      if page > 0
        @response.write(@rendeler.pagination_link(page - 1, "<<"))
      end
      last_page.times do |i|
        if i == page
          @response.write(@rendeler.pagination_span(i))
        else
          @response.write(@rendeler.pagination_link(i, i))
        end
      end
      if page < (last_page - 1)
        @response.write(@rendeler.pagination_link(page + 1, ">>"))
      end
      @response.write("</div>\n")
    end

    def render_footer
      @response.write @rendeler.footer
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
      (@request['page'] || 0).to_i
    end
  end
end

