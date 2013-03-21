# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/03/15

module Milkode
  MatchLineResult = Struct.new(:index, :match_datas)
  
  class WideMatcher
    attr_reader :num_max
    
    def initialize(num_max)
      @num_max   = num_max
      @container = []
    end

    def linenum
      @container.size
    end

    def add_line_matchs(index, matches)
      @last_index = index
      @container.shift if @num_max > 0 && linenum >= @num_max
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

    def match_lines
      index = @last_index - @container.size + 1
      @container.reduce([]) do |result, matches|
        m = matches.compact
        result << MatchLineResult.new(index, m) unless m.empty?
        index += 1
        result
      end
    end
  end
end


