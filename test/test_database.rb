# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'rubygems'
require 'groonga'
require 'test_helper' 
require 'file_test_utils'
require 'stringio'
require 'cdstk/cdstk'
require 'codestock/cdweb/lib/database'

module CodeStock
  class TestDatabase < Test::Unit::TestCase
    include FileTestUtils

    def test_setup_and_open
      io = StringIO.new
      obj = Cdstk.new(io)
      obj.init

      Database.setup('.')
      Database.instance
    end

    def teardown
      teardown_custom(true)
      #    teardown_custom(false)
    end
  end
end


