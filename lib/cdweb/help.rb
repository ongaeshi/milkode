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

module Grenweb
  class Help
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
      r = HTMLRendeler.new(@request.script_name + '/..')
      @response.write r.header("gren - help", "gren - help")
      @response.write r.sample_code
      @response.write r.footer
      @response.to_a
    end
  end
end

