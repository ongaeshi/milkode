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
          /#{Regexp.escape(i).gsub('\\*', ".*")}/
        else
          i
        end
      end
    end

    def ignore?(path)
      return false unless path.start_with?(@path)

      path = path[@path.size..-1]

      return false if path.empty?

      is_ignore = @matcher.any? do |i|
        if i.is_a?(Regexp)
          path.match i
        else
          path.include? i
        end
      end

      return is_ignore
    end
  end
end
