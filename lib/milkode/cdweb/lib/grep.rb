# -*- coding: utf-8 -*-
#
# @file 
# @brief  grenwebで使用する行指向の検索
# @author ongaeshi
# @date   2010/10/18

require 'milkode/common/util'
require 'milkode/common/wide_matcher'

module Milkode
  class Grep
    def initialize(content)
      @content = content
    end

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

    # 複数行間にキーワードが存在すればマッチする
    MATCH_RANGE = 7
    def match_lines_stopover_wide(patterns, max_match, start_index, is_sensitive)
      result = []
      patternRegexps = strs2regs(patterns, is_sensitive)
      index = start_index

      lines = @content.split($/)

      while (index < lines.size) do
        currentline = lines[index]

        # 一度でもマッチしたらtrue
        flags = Array.new(patternRegexps.size)

        # マッチ情報
        match_datas = []

        # result小計
        rsub = []

        # マッチするかテスト
        patternRegexps.each_with_index do |regexp, no|
          matched     =  regexp.match(currentline)
          flags[no]   |= matched
          match_datas << matched
        end

        # ある行にキーワードのどれかがマッチ
        if match_datas.any?
          # マッチ行情報を追記
          rsub << MatchLineResult.new(index, match_datas)

          # マッチ情報をリセット
          match_datas = []          
          
          # 現在行からMATCH_RANGE離れた所まで検索対象を広げる
          (1...MATCH_RANGE).each do |i|
            break if index + i >= lines.size
            line = lines[index + i]

            # マッチするかテスト
            patternRegexps.each_with_index do |regexp, no|
              matched     =  regexp.match(line)
              flags[no]   |= matched
              match_datas << matched
            end

            # マッチ行情報を追記
            rsub << MatchLineResult.new(index + i, match_datas) if match_datas.all?
          end

          # 全てのキーワードがマッチしていれば成功
          if flags.all?
            result += rsub
            if result.size >= max_match
              index += 1
              break
            end
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

