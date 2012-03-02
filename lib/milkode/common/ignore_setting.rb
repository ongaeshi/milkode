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
    
    def initialize(path, ignores)
      @path = path
      @ignores = ignores

      @matcher = @ignores.map do |i|
        if (i.include? '*')
          Regexp.new(Regexp.escape(i).gsub('\\*', "[^/]*"))
        else
          i
        end
      end
    end

    def ignore?(path)
      return false unless path.start_with?(@path)

      if (path.size == @path.size)
        false
      else
        ignore_in?(path[@path.size..-1])
      end
    end

    def ignore_in?(path)
      @matcher.each_with_index do |value, index|
        is_match_start_pos = @ignores[index].start_with?('/')
        
        if value.is_a?(Regexp)
          if is_match_start_pos
            match = path.match(value)
            return true if match && match.begin(0) == 0
          else
            return true if path.match(value)
          end
        else
          if is_match_start_pos
            return true if path.start_with?(value)
          else
            return true if path.include?(value)
          end
        end
      end
      
      return false
    end
  end
end
