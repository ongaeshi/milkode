# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'milkode/common/dir'
require 'test/unit'
require 'file_test_utils'

class TestDir < Test::Unit::TestCase
  include FileTestUtils

  def test_emptydir?
    assert_equal true, Dir.emptydir?(".")
    assert_equal false, Dir.emptydir?("..")
  end
end


