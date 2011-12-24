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

  def test_main
    t_setdb_set
    t_setdb_reset
  end
  
  def teardown
    @work.teardown
  end

  private

  def t_setdb_set
    # デフォルトデータベースの切り替え
    CdstkCommand.setdb_set(@work.expand_path "db1")

    # デフォルトデータベースの切り替え
    # @work.init_db( "db2" )
    # CdstkCommand.setdb_set(@work.expand_path "db2")
    
    # 存在していないデータベースを指定するとエラー
    assert_raise(Milkode::CdstkCommand::NotExistDatabase) { CdstkCommand.setdb_set("not_found") } 
  end

  def t_setdb_reset
    path = @work.expand_path '.milkode_db_dir'

    CdstkCommand.setdb_set(@work.expand_path "db1")
    assert File.exist?(path)

    CdstkCommand.setdb_reset
    assert !File.exist?(path)
  end
end


