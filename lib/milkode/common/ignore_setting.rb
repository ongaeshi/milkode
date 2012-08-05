# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/02

require 'pathname'

module Milkode
  class IgnoreSetting
    attr_reader :path
    attr_reader :ignores

    def self.create_from_gitignore(path, str)
      IgnoreSetting.new(path, parse_gitignore(str))
    end

    def self.parse_gitignore(str)
      ignores = str.split($/)
      ignores.delete_if{|v| v =~ /(\A#.*)|(\A\Z)/}
      ignores
    end
    
    def initialize(path, ignores)
      @path = path
      @ignores =  []
      @not_ignores = []
      
      ignores.each do |v|
        v = v.sub(/\/\Z/, "")

        unless v.start_with?('!')
          @ignores << v
        else
          @not_ignores << v.sub(/\A!/, "")
        end
      end

      # 除外設定 -> 正規表現
      @regexps = @ignores.map {|v| convert_regexp(v)}

      # 非除外設定 -> 展開 -> 正規表現
      new_not_ignores = []
      @not_regexps = []
      
      @not_ignores.each do |v|
        last_regexp = "(\/|\\Z)" # 自分自身は後方マッチ可

        Pathname.new(v).ascend do |pathname|
          txt = pathname.to_s
          new_not_ignores << txt
          @not_regexps << convert_regexp(txt, last_regexp)
          last_regexp = "\\Z"   # 親ディクレクリは後方マッチ不可
        end
      end

      @not_ignores = new_not_ignores
    end

    def ignore?(path)
      return false unless path.start_with?(@path)

      if (path.size == @path.size)
        false
      else
        if (@path == '/')
          ignore_in?(path)
        else
          ignore_in?(path[@path.size..-1])
        end
      end
    end

    private

    def ignore_in?(path)
      match_in?(path, @regexps, @ignores) &&
        !match_in?(path, @not_regexps, @not_ignores)
    end

    def match_in?(path, regexps, ignores)
      regexps.each_with_index do |value, index|
        match = path.match(value)
        is_match_start_pos = ignores[index].start_with?('/')

        if match && (!is_match_start_pos || match.begin(0) == 0)
          return true
        end
      end
      
      return false
    end

    def convert_regexp(txt, last_regexp = "(\/|\\Z)")
      v = "(\/|\\A)" + Regexp.escape(txt).gsub('\\*', "[^/]*") + last_regexp
      Regexp.new(v)
    end
  end
end
