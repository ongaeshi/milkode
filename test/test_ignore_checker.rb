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
    settings = [
      IgnoreSetting.new("/", ["/rdoc", "/test/data", "*.lock"]),
      IgnoreSetting.new("/pkg", ["*.gem"]),
    ]
    
    checker = IgnoreChecker.new(settings)

    assert_equal false, checker.ignore?("lib/test.rb")
    # assert_equal true, checker.ignore?("rdoc")
    # assert_equal true, checker.ignore?("rdoc/hoge.html")
  end
end
