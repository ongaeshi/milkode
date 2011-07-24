# -*- coding: utf-8 -*-
#
# @file 
# @brief  grenwebで使用する行指向の検索
# @author ongaeshi
# @date   2010/10/18

module Milkode
  class Grep
    def initialize(content)
      @content = content
    end

    MatchLineResult = Struct.new(:index, :match_datas)
    
    def match_lines_and(patterns)
      result = []
      patternRegexps = strs2regs(patterns, true)
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

    def one_match_and(patterns)
      patternRegexps = strs2regs(patterns, true)
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
    
    def strs2regs(strs, ignore = false)
      regs = []

      strs.each do |v|
        option = 0
        option |= Regexp::IGNORECASE if (ignore)
        regs << Regexp.new(v, option)
      end

      regs
    end
  end
end

