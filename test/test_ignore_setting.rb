# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/02

require 'milkode/common/ignore_setting.rb'
require 'test_helper'

class TestIgnoreSetting < Test::Unit::TestCase
  include Milkode
  
  def test_basic
    is = IgnoreSetting.new "/", ["rdoc", "*.bak"]

    assert_equal "/", is.path
    assert_equal ["rdoc", "*.bak"], is.ignores
  end

  def test_basic2
    is = IgnoreSetting.new "/pkg", ["*.gem"]

    assert_equal "/pkg", is.path
    assert_equal ["*.gem"], is.ignores
  end

  def test_ignore?
    is = IgnoreSetting.new "/doc", ["test", "*.bak"]

    assert_equal false, is.ignore?("/lib/hoge.rb")
    assert_equal false, is.ignore?("/doc")
    
    assert_equal true,  is.ignore?("/doc/test")
    assert_equal false, is.ignore?("/doc/tesa")
    assert_equal true,  is.ignore?("/doc/test.html")
    
    assert_equal false, is.ignore?("/hoge.bak")
    assert_equal true,  is.ignore?("/doc/hoge.bak")
    assert_equal false, is.ignore?("/doc/hoge@bak")
    assert_equal false, is.ignore?("/doc/hoge.c")
  end
end




