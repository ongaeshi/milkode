# -*- coding: utf-8 -*-
#
# @file 
# @brief  grenwebで使用する行指向の検索
# @author ongaeshi
# @date   2010/10/18

module Grenweb
  class Grep
    attr_reader :content
    
    def initialize(content)
      @content = content.split("\n")
    end

    MatchLineResult = Struct.new(:index, :match_datas)
    
    def match_lines_or(patterns)
      result = []
      patternRegexps = strs2regs(patterns, true) # @todo ignoreオプションを付ける
      
      @content.each_with_index do |line, index|
        match_datas = []
        patternRegexps.each {|v| match_datas << v.match(line)}

        if (match_datas.any?)
          result << MatchLineResult.new(index, match_datas)
        end
      end
      
      result
    end

    def context(result, num)
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

