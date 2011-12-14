# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'milkode_test_work'
require 'milkode/cdstk/cdstk_command'

class TestCdstkCommand < Test::Unit::TestCase
  def setup
    @work = MilkodeTestWork.new({:default_db => true})
  end

  def test_setdb_set
    obj = CdstkCommand.new 

    # デフォルトデータベースの切り替え
    obj.setdb_set(@work.expand_path "db1")

    # デフォルトデータベースの切り替え
    @work.init_db("db2")
    obj.setdb_set(@work.expand_path "db2")
    
    # 存在していないデータベースを指定するとエラー
    assert_raise(Milkode::CdstkCommand::NotExistDatabase) { obj.setdb_set("not_found") } 
  end

  def test_setdb_reset
    obj = CdstkCommand.new

    path = @work.expand_path '.milkode_db_dir'

    obj.setdb_set(@work.expand_path "db1")
    assert File.exist?(path)

    obj.setdb_reset
    assert !File.exist?(path)
  end

  def teardown
    @work.teardown
  end
end


