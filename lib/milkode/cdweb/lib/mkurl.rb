# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/13

require 'rubygems'
require 'rack'

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

    def inherit_query_shead_set_sort(sort_kind)
      create_url(query_param(true, true, false, sort_kind))
    end

    def inherit_query_shead
      create_url(query_param(true, true, false))
    end

    def inherit_shead
      create_url(query_param(false, true, false))
    end

    private

    def escape_path(src)
      # /rack-1.3.0/lib/rack/utils.rb:29
      Rack::Utils::escape_path(src).gsub("%2F", '/')
    end

    def escape(src)
      Rack::Utils::escape(src)
    end

    def create_url(qp)
      if (qp == "")
        @path
      else
        "#{@path}?#{qp}"
      end
    end

    def query_param(query_inherit, shead_inherit, offset_inherit, sort_kind = nil)
      qparam = []
      qparam << "query=#{escape(@params[:query])}" if (query_inherit and @params[:query])
      qparam << "shead=#{escape(@params[:shead])}" if (shead_inherit and @params[:shead])
      qparam << "onematch=#{escape(@params[:onematch])}" if (shead_inherit and @params[:onematch])
      qparam << "sensitive=#{escape(@params[:sensitive])}" if (shead_inherit and @params[:sensitive])
      qparam << "offset=#{escape(@params[:offset])}" if (offset_inherit and @params[:offset])
      qparam << "line=#{escape(@params[:line])}" if (offset_inherit and @params[:line])
      qparam << "sort=#{sort_kind}" if sort_kind
      qparam.join('&')
    end
  end
end



