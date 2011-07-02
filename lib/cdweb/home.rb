# -*- coding: utf-8 -*-
#
# @file 
# @brief  ホーム画面
# @author ongaeshi
# @date   2010/10/13

require 'rubygems'
require 'rack'
require 'cdweb/database'
require 'cdweb/html_renderer'
require 'cdweb/query'

module CodeStock
  class Home
    include Rack::Utils

    def call(env)
      @env = env
      @request = Rack::Request.new(env)
      @query = Query.new(@request)

      @response = Rack::Response.new
      @response["Content-Type"] = "text/html; charset=UTF-8"

      render
    end

    private

    def render
      r = HTMLRendeler.new(@request.script_name)
      @response.write r.header_home("gren", "gren", Version)
      @response.write r.search_box
      @response.write r.footer_home("??", Database.instance.fileNum)
      @response.to_a
    end
  end
end

