# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/09/12

require 'test_helper'
require 'milkode/database/updater'
require 'milkode_test_work'

module Milkode
  class TestUpdater < Test::Unit::TestCase
    def setup
      @work = MilkodeTestWork.new({:default_db => true})
      @work.add_package "db1", @work.expand_path("../data/a_project")
      @grndb = GroongaDatabase.new
      @grndb.open(@work.expand_path("db1"))
    end
    
    def test_update
      # pre check
      assert_equal    1, @grndb.packages.size
      assert_not_nil  @grndb.packages['a_project']

      # do update
      updater = Updater.new(@grndb, 'a_project')
      updater.exec
    end

    def teardown
      @work.teardown
    end
  end
end
