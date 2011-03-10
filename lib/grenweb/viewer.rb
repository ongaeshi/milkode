# -*- coding: utf-8 -*-
#
# @file 
# @brief  ソースコードを表示する
# @author ongaeshi
# @date   2010/10/13

require 'rack'
require File.join(File.dirname(__FILE__), 'database')
require File.join(File.dirname(__FILE__), 'html_renderer')

module Grenweb
  class Viewer
    include Rack::Utils

    def initialize
    end
    
    def call(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      @response["Content-Type"] = "text/html; charset=UTF-8"

      record, elapsed = Database.instance.record(req2query)

      @rendeler = HTMLRendeler.new(@request.script_name + '/..')

      if (record)
        @response.write @rendeler.header("gren : #{record.shortpath}", "gren")
        @response.write @rendeler.search_box("")
        @response.write @rendeler.view_summary(record.shortpath, elapsed)
        @response.write @rendeler.record_content(record)
      else
        @response.write @rendeler.header("gren : not found.", "gren")
        @response.write @rendeler.search_box("")
        @response.write @rendeler.empty_summary
      end
      @response.write @rendeler.footer
      
      @response.to_a
    end

    private

    def req2query
      p @request.path_info
      unescape(@request.path_info.gsub(/\A\/|\/z/, ''))
    end
    
  end
end
