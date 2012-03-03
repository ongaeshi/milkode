# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/02

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
      @ignores = ignores

      @regexp = @ignores.map do |v|
        v = Regexp.escape(v).gsub('\\*', "[^/]*") + "(\/|\\Z)"
        Regexp.new(v)
      end
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
      @regexp.each_with_index do |value, index|
        match = path.match(value)
        is_match_start_pos = @ignores[index].start_with?('/')

        if match && (!is_match_start_pos || match.begin(0) == 0)
          return true
        end
      end
      
      return false
    end
  end
end
