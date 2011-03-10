# -*- coding: utf-8 -*-

require File.join(File.dirname(__FILE__), 'string_snip')

class GrenSnip
  MAX_LINE_SIZE = 256
  HEADER_SIZE = 32
  MARGIN_SIZE = 32
  DELIMITER = '<<snip>>'

  def self.snip(str, match_datas)
    return str if (str.size <= MAX_LINE_SIZE)

    ranges = []
    ranges << (0..HEADER_SIZE-1)
    ranges << (-HEADER_SIZE..-1)

    match_datas.each do |m|
      ranges << (m.begin(0)-MARGIN_SIZE..m.end(0)+MARGIN_SIZE)
    end

    snipper = StringSnip.new(MAX_LINE_SIZE, DELIMITER)
    return snipper.snip(str, ranges)
  end

  def self.coloring(line, match_datas)
    match_datas.each do |m|
      line = line.split(m[0]).join(HighLine::ON_GREEN + m[0] + HighLine::CLEAR)
    end
    
    line = line.split(DELIMITER).join(HighLine::ON_CYAN + DELIMITER + HighLine::CLEAR)

    line
  end
end


