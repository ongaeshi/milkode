# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/02

require 'milkode/common/ignore_setting.rb'
require 'test_helper'

class TestIgnoreSetting < Test::Unit::TestCase
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
end




