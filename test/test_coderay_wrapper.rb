# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/16

require 'test_helper'
require 'file_assert'
require 'test_coderay_wrapper_data'
require 'codestock/cdweb/lib/coderay_wrapper'

module CodeStock
  class TestCodeRayWrapper < Test::Unit::TestCase
    def test_basic
      assert_lines JS_SHORT_HTML, CodeRayWrapper.html_memfile(JS_SHORT_CODE, "console-dir.js")
      assert_lines JS_HTML, CodeRayWrapper.html_memfile(JS_CODE, "console-dir.js")
    end
  end
end


