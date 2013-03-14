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
eee
EOF

  def test_initialize
    obj = WideMatcher.new(5)
    assert_equal 5, obj.num_max
    assert_equal 0, obj.linenum
  end

  def test_add_line_matches
    lines   = SRC.split("\n")
    regexps = strs2regs(['a', 'c'])
    
    obj = WideMatcher.new(3)

    obj.add_line_matchs( match_regexps(lines[0], regexps) )
    assert_equal false, obj.match?

    obj.add_line_matchs( match_regexps(lines[1], regexps) )
    assert_equal false, obj.match?

    obj.add_line_matchs( match_regexps(lines[2], regexps) )
    assert_equal true, obj.match?
    # p obj.realy_matches.map {|v| v.string }

    obj.add_line_matchs( match_regexps(lines[3], regexps) )
    assert_equal false, obj.match?

    obj.add_line_matchs( match_regexps(lines[4], regexps) )
    assert_equal false, obj.match?
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
