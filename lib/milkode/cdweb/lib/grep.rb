# -*- coding: utf-8 -*-
#
# @file 
# @brief  grenwebで使用する行指向の検索
# @author ongaeshi
# @date   2010/10/18

require 'milkode/common/util'

module Milkode
  class Grep
    def initialize(content)
      @content = content
    end

    MatchLineResult = Struct.new(:index, :match_datas)

    def match_lines_stopover(patterns, max_match, start_index, is_sensitive)
      result = []
      patternRegexps = strs2regs(patterns, is_sensitive)
      index = start_index

      lines = @content.split($/)

      while (index < lines.size) do
        line = lines[index]

        match_datas = []
        patternRegexps.each {|v| match_datas << v.match(line)}

        if (match_datas.all?)
          result << MatchLineResult.new(index, match_datas)
          if result.size >= max_match
            index += 1
            break
          end
        end

        index += 1
      end

      index = 0 if (index >= lines.size)
      {:result => result, :next_line => index}
    end
    
    def match_lines_and(patterns, is_sensitive)
      result = []
      patternRegexps = strs2regs(patterns, is_sensitive)
      index = 0
      
      @content.each_line do |line|
        match_datas = []
        patternRegexps.each {|v| match_datas << v.match(line)}

        if (match_datas.all?)
          result << MatchLineResult.new(index, match_datas)
        end

        index += 1
      end
      
      result
    end

    def one_match_and(patterns, is_sensitive)
      patternRegexps = strs2regs(patterns, is_sensitive)
      index = 0
      
      @content.each_line do |line|
        match_datas = []
        patternRegexps.each {|v| match_datas << v.match(line)}

        if (match_datas.all?)
          return MatchLineResult.new(index, match_datas)
        end

        index += 1
      end
      
      nil
    end

    private
    
    def strs2regs(strs, is_sensitive)
      regs = []

      strs.each do |v|
        option = 0
        option |= Regexp::IGNORECASE if (!is_sensitive && Util::downcase?(v))
        regs   << Regexp.new(Regexp.escape(v), option)
      end

      regs
    end
  end
end

