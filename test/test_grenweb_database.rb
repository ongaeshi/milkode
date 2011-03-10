# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'rubygems'
require 'groonga'
require File.join(File.dirname(__FILE__), "test_helper")
require File.join(File.dirname(__FILE__), "file_test_utils")
require File.join(File.dirname(__FILE__), "../lib/grenweb/database")
require File.join(File.dirname(__FILE__), "../lib/common/dbdir")
require File.join(File.dirname(__FILE__), "../lib/mkgrendb/mkgrendb")
require 'stringio'

class TestMkgrendb < Test::Unit::TestCase
  include Grenweb
  include FileTestUtils
  include CodeStock

  def test_setup_and_open
    io = StringIO.new
    obj = Mkgrendb::Mkgrendb.new(io)
    obj.init

    Database.setup('.')
    Database.instance
  end

  def teardown
    teardown_custom(true)
#    teardown_custom(false)
  end
end


