# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/09/29

require 'milkode/common/plang_detector'
require 'test_helper'

module Milkode
  class TestPlangDetector < Test::Unit::TestCase
    def test_name
      assert_equal 'ActionScript', PlangDetector.new('Dummy.as').name
      assert_equal 'C'           , PlangDetector.new('a.c').name
      assert_equal 'C'           , PlangDetector.new('a.h').name
      assert_equal 'C#'          , PlangDetector.new('AssemblyInfo.cs').name
      assert_equal 'C++'         , PlangDetector.new('path/to/file.hpp').name
      assert_equal 'Ruby'        , PlangDetector.new('template.rb').name
      assert_equal 'Text'        , PlangDetector.new('readme.txt').name
      assert_equal 'JavaScript'  , PlangDetector.new('main.js').name
    end

    def test_unknown
      assert_equal 'unknown', PlangDetector.new('').name
      assert_equal 'unknown', PlangDetector.new('.').name
      assert_equal 'unknown', PlangDetector.new('abcdefg').name
    end
  end
end


