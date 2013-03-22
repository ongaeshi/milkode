# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'test_helper'
require 'milkode/common/wide_matcher'

class TestWideMatcher < Test::Unit::TestCase
  include Milkode

  SRC = <<EOF
aaa
bbb
ccc
ddd
aaa
EOF

  def test_initialize
    obj = WideMatcher.create(5)
    assert_equal 5, obj.num_max
    assert_equal 0, obj.linenum
  end

  def test_add_line_matches
    lines   = SRC.split("\n")
    regexps = strs2regs(['a', 'c'])
    
    obj = WideMatcher.create(3)

    obj.add_line_matchs( 0, match_regexps(lines[0], regexps) )
    assert_equal false, obj.match?

    obj.add_line_matchs( 1, match_regexps(lines[1], regexps) )
    assert_equal false, obj.match?

    obj.add_line_matchs( 2, match_regexps(lines[2], regexps) )
    assert_equal true, obj.match?
    assert_equal [0, 2], obj.match_lines.map{|v| v.index}

    obj.add_line_matchs( 3, match_regexps(lines[3], regexps) )
    assert_equal false, obj.match?

    obj.add_line_matchs( 4, match_regexps(lines[4], regexps) )
    assert_equal true, obj.match?
    assert_equal [2, 4], obj.match_lines.map{|v| v.index}
  end

  private

  def strs2regs(strs)
    strs.map do |v|
      Regexp.new(Regexp.escape(v))
    end
  end

  def match_regexps(line, regexps)
    regexps.map {|v| v.match(line)}
  end
  
end
