# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/16

require 'test_helper'
require 'file_assert'
require 'test_coderay_wrapper_data'
require 'milkode/cdweb/lib/coderay_wrapper'

module Milkode
  class TestCodeRayWrapper < Test::Unit::TestCase
    def test_basic
      assert_lines JS_SHORT_HTML, CodeRayWrapper.new(JS_SHORT_CODE, "console-dir.js").to_html
      assert_lines JS_HTML      , CodeRayWrapper.new(JS_CODE, "console-dir.js").to_html 
    end
  end
end


