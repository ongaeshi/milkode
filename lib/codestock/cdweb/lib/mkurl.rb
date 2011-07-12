# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/13

require 'rubygems'
require 'rack'
include Rack::Utils

module CodeStock
    class Mkurl
    def initialize(path, params)
      @path = path
      @params = params
    end

    def inherit_query_shead_page
      create_url(query_param(true, true, true))
    end

    def inherit_query_shead
      create_url(query_param(true, true, false))
    end

    def inherit_shead
      create_url(query_param(false, true, false))
    end

    private

    def create_url(qp)
      if (qp == "")
        @path
      else
        "#{@path}?#{qp}"
      end
    end

    def query_param(query_inherit, shead_inherit, page_inherit)
      qparam = []
      qparam << "query=#{escape(@params[:query])}" if (query_inherit and @params[:query])
      qparam << "shead=#{escape(@params[:shead])}" if (shead_inherit and @params[:shead])
      qparam << "page=#{escape(@params[:page])}" if (page_inherit and @params[:page])
      qparam.join('&')
    end
  end
end



