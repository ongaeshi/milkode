# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/03/15

module Milkode
  class WideMatcher
    attr_reader :num_max
    
    def initialize(num_max)
      @num_max   = num_max
      @container = []
    end

    def linenum
      @container.size
    end

    def add_line_matchs(matches)
      @container.shift if linenum >= @num_max
      @container << matches
      # p @container
    end

    def match?
      @container.reduce(Array.new(@container.first.size)) {|result, matches|
        matches.each_with_index do |m, i|
          result[i] |= m
        end
        result
      }.all?
    end

    def realy_matches
      a = @container.flatten
      a.delete(nil)
      a
    end

  end
end


