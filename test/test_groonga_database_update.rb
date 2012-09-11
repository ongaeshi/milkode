# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/09/12

require 'test_helper'
require 'milkode/database/groonga_database'
require 'milkode_test_work'

module Milkode
  class TestGroongaDatabaseUpdate < Test::Unit::TestCase
    def setup
      @work = MilkodeTestWork.new({:default_db => true})
      @work.add_package "db1", @work.expand_path("../data/a_project")
      @obj = GroongaDatabase.new
      @obj.open(@work.expand_path("db1"))
    end
    def test_update
      # pre check
      assert_equal    1, @obj.packages.size
      assert_not_nil  @obj.packages['a_project']

      # update test
      @obj.update('a_project')
    end

    def teardown
      @work.teardown
    end
  end
end
