# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/02

require 'milkode/common/ignore_checker.rb'
require 'test_helper'

class TestIgnoreChecker < Test::Unit::TestCase
  include Milkode
  
  def test_basic
    c = IgnoreChecker.new
    c.add IgnoreSetting.new("/", ["/rdoc", "/test/data", "*.lock"])
    c.add IgnoreSetting.new("/pkg", ["*.gem"])

    assert_equal false, c.ignore?("/lib/test.rb")
    assert_equal true,  c.ignore?("/pkg/hoge.gem")
    assert_equal false,  c.ignore?("/pkg/hoge.txt")
    assert_equal true,  c.ignore?("/test.lock")
    assert_equal true,  c.ignore?("/rdoc")
    assert_equal true,  c.ignore?("/test/data")
  end
end
