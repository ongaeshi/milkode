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
require 'cdweb/database'
require 'common/dbdir'
require 'cdstk/cdstk'
require 'stringio'

class TestMkgrendb < Test::Unit::TestCase
  include FileTestUtils
  include CodeStock

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


