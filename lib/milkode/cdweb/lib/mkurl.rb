# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/13

require 'rubygems'
require 'rack'
include Rack::Utils

module Milkode
  class Mkurl
    def initialize(path, params)
      @path = escape_path(path)
      @params = params
    end

    def inherit_query_shead_offset
      create_url(query_param(true, true, true))
    end

    def inherit_query_shead
      create_url(query_param(true, true, false))
    end

    def inherit_shead
      create_url(query_param(false, true, false))
    end

    private

    def escape_path(src)
      escape(src).gsub("%2F", '/')
    end

    def create_url(qp)
      if (qp == "")
        @path
      else
        "#{@path}?#{qp}"
      end
    end

    def query_param(query_inherit, shead_inherit, offset_inherit)
      qparam = []
      qparam << "query=#{escape(@params[:query])}" if (query_inherit and @params[:query])
      qparam << "shead=#{escape(@params[:shead])}" if (shead_inherit and @params[:shead])
      qparam << "offset=#{escape(@params[:offset])}" if (offset_inherit and @params[:offset])
      qparam.join('&')
    end
  end
end



