# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/09/12

require 'test_helper'
require 'milkode/database/updater'
require 'milkode_test_work'
require 'fileutils'

module Milkode
  class TestUpdater < Test::Unit::TestCase
    def setup
      @work = MilkodeTestWork.new({:default_db => true})
      FileUtils.cp_r @work.expand_path("../data/a_project"), @work.expand_path("a_project")
      @work.add_package "db1", @work.expand_path("a_project")
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
      result_test updater.result, 3, 0, 0

      # add file
      FileUtils.touch(@work.expand_path("a_project/aaa"), :mtime => Time.now - 1)
      updater = Updater.new(@grndb, 'a_project')
      updater.exec
      result_test updater.result, 4, 1, 0

      # update file
      FileUtils.copy @work.expand_path("../data/c_project/a.txt"), @work.expand_path("a_project/aaa")
      FileUtils.touch(@work.expand_path("a_project/aaa"))
      updater = Updater.new(@grndb, 'a_project')
      updater.exec
      result_test updater.result, 4, 0, 1
    end

    def teardown
      @work.teardown
    end

    private

    def result_test(result, file_count, add_count, update_count)
      assert_equal file_count, result.file_count 
      assert_equal add_count, result.add_count 
      assert_equal update_count, result.update_count 
    end
  end
end
