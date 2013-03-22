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

    def self.create(num_max)
      if num_max == 0
        WideMatcherZero.new
      else
        WideMatcher.new(num_max)
      end
    end
    
    def initialize(num_max)
      @num_max   = num_max
      @container = []
    end

    def linenum
      @container.size
    end

    def add_line_matchs(index, matches)
      @last_index = index
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

  class WideMatcherZero
    attr_reader :num_max

    def initialize
      @num_max   = 0
    end

    def linenum
      1
    end

    def add_line_matchs(index, matches)
      @index   = index
      @matches = matches
    end

    def match?
      @matches.any?
    end

    def match_lines
      [MatchLineResult.new(@index, @matches.compact)]
    end
  end
end


