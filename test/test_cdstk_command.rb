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
    assert true
  end
  
#   def test_setdb_set
#     # デフォルトデータベースの切り替え
#     obj.setdb_set("milkode_test_work/db")

#     # デフォルトデータベースの切り替え
#     MilkodeTestUtils.init_db("milkode_test_work/db2") do
#         obj.setdb_set("milkode_test_work/db2")
#     end
    
#     # 存在していないデータベースを指定するとエラー
#     assert_raise(Milkode::CdstkCommand::NotExistDatabase) { obj.setdb_set("not_found") } 
#   end

#   def test_setdb_reset
#     obj.setdb_set("milkode_test_work/db")
#     assert File.exist?('milkode_test_work/.milkode_db_dir')
#     obj.setdb_reset
#     assert !File.exist?('milkode_test_work/.milkode_db_dir')
#   end

  def teardown
    @work.teardown
  end
end


