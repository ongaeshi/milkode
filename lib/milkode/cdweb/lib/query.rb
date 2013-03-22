# -*- coding: utf-8 -*-
#
# @file 
# @brief  クエリーの解析
# @author ongaeshi
# @date   2010/10/21

require 'rubygems'
require 'rack'

module Milkode
  class Query
    attr_reader :query_string

    OPTIONS = [
               ['package'  , 'p'],
               ['filepath' , 'fpath', 'f'],
               ['suffix'   , 's'],
               ['fp']      , # fpath or package
               ['keyword'  , 'k'],
               ['gotoline' , 'g'],
               ['wide'     , 'w'],
              ]

    def initialize(str)
      @query_string = str
      init_hash
      parse
      @wide_match_range = calc_param(6)
    end

    def escape_html
      Rack::Utils::escape_html(@query_string)
    end

    def empty?
      keywords.size == 0 && only_keywords
    end

    def only_keywords
      packages.size == 0 && fpaths.size == 0 && suffixs.size == 0 && fpath_or_packages.size == 0 && gotolines.size == 0 && wide_match_range_empty?
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

    def fpath_or_packages
      calc_param(3)
    end

    def multi_match_keywords
      # 本当はkeywordsにしたかった・・
      calc_param(4)
    end

    def gotolines
      calc_param(5)
    end

    def wide_match_range
      a = @wide_match_range

      if a.empty?
        1
      else
        i = a[-1].to_i

        if (i == 0)
          0
        else
          i
        end
      end
    end

    def wide_match_range_empty?
      @wide_match_range.empty?
    end

    def conv_keywords_to_fpath
      s = query_string.split.map {|v|
        if keywords.include? v
          "f:#{v}"
        else
          v
        end
      }.join(' ')

      Query.new(s)
    end

    def conv_keywords_to_fpath_or_packages
      s = query_string.split.map {|v|
        if keywords.include? v
          "fp:#{v}"
        else
          v
        end
      }.join(' ')

      Query.new(s)
    end

    # 'name def test' -> 'fp:name def test'
    def conv_head_keyword_to_fpath_or_packages
      s = query_string.split.map {|v|
        if keywords[0].include? v
          "fp:#{v}"
        else
          v
        end
      }.join(' ')

      Query.new(s)
    end

    # 'cdstk.rb:11' -> 'g:cdstk.rb:11'
    def conv_fuzzy_gotoline
      s = query_string.split.map {|v|
        if keywords[0].include? v
          "g:#{v}"
        else
          v
        end
      }.join(' ')

      Query.new(s)
    end

    def conv_wide_match_range(match_range)
      Query.new(query_string + " w:#{match_range}")
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

