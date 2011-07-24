# -*- coding: utf-8 -*-

class StringSnip
  def initialize(size = 256, delimiter = '<<snip>>', pri = nil)
    @size = size
    @delimiter = delimiter
    @pri = pri
  end

  def snip(str, ranges)
    @str = str
    @ranges = ranges

    # no snip
    return @str if (@str.size <= @size)

    # snip
    @ranges = StringSnip::ranges_conv(@ranges, @str)
    @ranges = StringSnip::ranges_sort(@ranges)
    @ranges = StringSnip::ranges_compound(@ranges)

    # result
    results = []
    @ranges.each {|r| results << @str[r] }
    return results.join(@delimiter)
  end

  def self.ranges_conv(ranges, str)
    ranges.map {|i| index_conv(str, i.begin)..index_conv(str, i.end)}
  end

  def self.index_conv(str, value)
    if (value < 0)
      str.size + value
    else
      value
    end
  end

  def self.ranges_sort(ranges)
    ranges.sort_by{|i| i.begin}
  end

  def self.ranges_compound(ranges)
    result = []
    
    index = 0
    while (ranges.size > 0)
      if (ranges.size > 1 && ranges[0].end + 1 >= ranges[1].begin)
        v1, v2 = ranges.shift(2)
        ranges.unshift v1.begin..((v1.end > v2.end) ? v1.end : v2.end)
      else
        result << ranges.shift
      end
    end

    result
  end
end


