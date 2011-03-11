# -*- coding: utf-8 -*-
#
# @file 
# @brief  クエリーの解析
# @author ongaeshi
# @date   2010/10/21

require 'rubygems'
require 'rack'

module Grenweb
  class Query
    include Rack::Utils
    attr_reader :query_string
  
    OPTIONS = [
               ['package',  'p'],
               ['filepath', 'fpath', 'f'],
               ['suffix',   's'],
              ]

    def initialize(request)
      @query_string = unescape(request.path_info.gsub(/\A\/|\/\z/, ''))
      init_hash
      parse
    end

    def escape_html
      Rack::Utils::escape_html(@query_string)
    end

    def empty?
      keywords.size == 0 && packages.size == 0 && fpaths.size == 0 && suffixs.size == 0
    end

    def keywords
      @hash['keywords']
    end

    def packages
      calc_param(0)
    end

    def fpaths
      calc_param(1)
    end

    def suffixs
      calc_param(2)
    end

    private

    def calc_param(index)
      OPTIONS[index].inject([]){|result, item| result.concat @hash[item] }
    end

    def init_hash
      @hash = {}
      @hash['keywords'] = []

      OPTIONS.flatten.each do |key|
        @hash[key] = []
      end
    end

    def parse
      kp = OPTIONS.flatten.join('|')
      parts = @query_string.scan(/(?:(#{kp}):)?(?:"(.+)"|(\S+))/)

      parts.each do |key, quoted_value, value|
        text = quoted_value || value
        unless (key)
          @hash['keywords'] << text
        else
          @hash[key] << text
        end
      end
    end
  end
end

