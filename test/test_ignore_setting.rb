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

  def test_regexp
    r = /test(\/|\Z)/

    assert_match r, "test"
    assert_match r, "test/"
    assert_not_match r, "testa"
    assert_match r, "test/foo"
    assert_not_match r, "testa/foo"
  end
  
  def test_reader
    is = IgnoreSetting.new "/pkg", ["rdoc", "*.bak"]

    assert_equal "/pkg", is.path
    assert_equal ["rdoc", "*.bak"], is.ignores
  end

  def test_ignore?
    is = IgnoreSetting.new "/doc", ["foo", "bar"]

    assert_equal false, is.ignore?("/lib/hoge.rb")
    assert_equal false, is.ignore?("/doc")

    assert_equal true,  is.ignore?("/doc/foo")
    assert_equal false, is.ignore?("/doc/foo_a")
    assert_equal true,  is.ignore?("/doc/foo/a.txt")
    assert_equal true,  is.ignore?("/doc/bar")
  end

  # def test_ignore?
  #   is = IgnoreSetting.new "/doc", ["test", "*.bak"]

  #   assert_equal false, is.ignore?("/lib/hoge.rb")
  #   assert_equal false, is.ignore?("/doc")
    
  #   assert_equal true,  is.ignore?("/doc/test")
  #   assert_equal false, is.ignore?("/doc/test_a")
  #   assert_equal true,  is.ignore?("/doc/foo/test")
    
  #   assert_equal false, is.ignore?("/doc/tesa")
  #   # assert_equal true,  is.ignore?("/doc/test.html")
    
  #   assert_equal false, is.ignore?("/hoge.bak")
  #   assert_equal true,  is.ignore?("/doc/hoge.bak")
  #   assert_equal false, is.ignore?("/doc/hoge@bak")
  #   assert_equal false, is.ignore?("/doc/hoge.c")
  # end

  # def test_ignore_slash?
  #   is = IgnoreSetting.new "/doc", ["/test", "/*.bak"]

  #   assert_equal true,  is.ignore?("/doc/test")
  #   assert_equal true,  is.ignore?("/doc/test/hoge.c")
  #   assert_equal false,  is.ignore?("/doc/a/test")
    
  #   # assert_equal false, is.ignore?("/hoge.bak")
  #   # assert_equal true,  is.ignore?("/doc/hoge.bak")
  #   # assert_equal false,  is.ignore?("/doc/dummy/foo.bak")
  # end

  # def test_root_ignore?
  #   is = IgnoreSetting.new("/", ["/rdoc", "/test/data", "/*.lock"])

  #   assert_equal true,  is.ignore?("/rdoc")
  #   assert_equal true,  is.ignore?("/test/data")
  #   assert_equal true,  is.ignore?("/dummy.lock")
  # end
end




