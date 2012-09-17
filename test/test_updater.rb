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
require 'milkode/common/ignore_checker'

module Milkode
  class TestUpdater < Test::Unit::TestCase
    def setup
      @work = MilkodeTestWork.new({:default_db => true})

      FileUtils.cp_r @work.expand_path("../data/a_project"), @work.expand_path("a_project")
      @work.add_package "db1", @work.expand_path("a_project")

      FileUtils.cp_r @work.expand_path("../data/ignore_test"), @work.expand_path(".")
      @work.add_package "db1", @work.expand_path("ignore_test")
      
      @grndb = GroongaDatabase.new
      @grndb.open(@work.expand_path("db1"))
    end
    
    def test_update
      t_pre_check
      t_update
      t_add_file
      t_update_file
      t_local_gitignore
      t_global_ignore
    end

    def teardown
      @work.teardown
    end

    private

    def t_pre_check
      assert_equal    2, @grndb.packages.size
      assert_not_nil  @grndb.packages['a_project']
    end

    def t_update
      updater = Updater.new(@grndb, 'a_project')
      updater.exec
      result_test updater.result, 3, 0, 0
    end

    def t_add_file
      FileUtils.touch(@work.expand_path("a_project/aaa"), :mtime => Time.now - 1)
      updater = Updater.new(@grndb, 'a_project')
      updater.exec
      result_test updater.result, 4, 1, 0
    end

    def t_update_file
      FileUtils.copy @work.expand_path("../data/c_project/a.txt"), @work.expand_path("a_project/aaa")
      FileUtils.touch(@work.expand_path("a_project/aaa"))
      updater = Updater.new(@grndb, 'a_project')
      updater.exec
      result_test updater.result, 4, 0, 1
    end

    def t_local_gitignore
      FileUtils.touch(@work.expand_path("ignore_test/b.bak")) # *.bak は除外対象
      FileUtils.touch(@work.expand_path("ignore_test/b.txt"))
      updater = Updater.new(@grndb, 'ignore_test')
      updater.exec
      result_test updater.result, 3, 1, 0
    end

    def t_global_ignore
      FileUtils.touch(@work.expand_path("ignore_test/c.txt"))

      updater = Updater.new(@grndb, 'ignore_test')
      updater.exec
      result_test updater.result, 4, 1, 0

      updater = Updater.new(@grndb, 'ignore_test')
      updater.set_global_ignore(IgnoreSetting.new("/", ["*.txt"])) # *.txt を除外設定
      updater.exec
      result_test updater.result, 1, 0, 0
    end

    def result_test(result, file_count, add_count, update_count)
      assert_equal file_count, result.file_count 
      assert_equal add_count, result.add_count 
      assert_equal update_count, result.update_count 
    end
  end
end
