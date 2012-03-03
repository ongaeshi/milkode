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
  
  def test_glob_regexp
    r = /[^\/]*bak(\/|\Z)/

    assert_match r, "hoge.bak"
    assert_not_match r, "hoge.cpp"
    assert_match r, "a/hoge.bak/test"
    assert_not_match r, "hoge.baka/test"
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

  def test_slash_ignore?
    is = IgnoreSetting.new "/doc", ["/foo"]

    assert_equal true,  is.ignore?("/doc/foo")
    assert_equal false, is.ignore?("/doc/bar/foo")
  end

  def test_glob_ignore?
    is = IgnoreSetting.new "/doc", ["*.bak"]

    assert_equal false, is.ignore?("/hoge.bak")
    assert_equal true,  is.ignore?("/doc/hoge.bak")
    assert_equal true,  is.ignore?("/doc/test/a.bak")
    assert_equal false, is.ignore?("/doc/hoge.baka")
    assert_equal false, is.ignore?("/doc/hoge@bak")
  end

  def test_slash_glob_ignore?
    is = IgnoreSetting.new "/doc", ["/*.bak"]

    assert_equal true,  is.ignore?("/doc/hoge.bak")
    assert_equal false,  is.ignore?("/doc/test/a.bak")
  end

  def test_multipath_ignore?
    is = IgnoreSetting.new "/doc", ["test/data"]

    assert_equal true,  is.ignore?("/doc/test/data/a.txt")
    assert_equal false, is.ignore?("/doc/test/dataa/a.txt")
  end
end




