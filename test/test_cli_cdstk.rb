# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/12/03

require 'milkode/cdstk/cli_cdstk.rb'
require 'milkode/common/dbdir'
require 'test_helper'
require 'milkode/cdstk/cdstk_command'

class TestCLI_Cdstk < Test::Unit::TestCase
  def setup
    @first_default_dir = Dbdir.default_dir
    @work = MilkodeTestWork.new({:default_db => true})
  end

  def test_mcd
    io = StringIO.new
    CLI_Cdstk.execute(io, "mcd".split)
    assert_match /mcd/, io.string
  end
  
  def test_setdb
    # 引数無しで現在の値を表示
    io = StringIO.new
    CLI_Cdstk.execute(io, "setdb".split)
    assert_equal @work.expand_path("db1") + "\n", io.string
    
    # .milkode_db_dir を書き換えてテスト
    io = StringIO.new
    open(@work.path(".milkode_db_dir"), "w") {|f| f.print "/a/custom/db" }
    CLI_Cdstk.execute(io, "setdb".split)
    assert_equal "/a/custom/db\n", io.string

    # データベースではないディレクトリに切り替ようとするとエラー
    io = StringIO.new
    CLI_Cdstk.execute(io, "setdb /a/write/test".split)
    assert_match /fatal:/, io.string
    
    @work.init_db("db2")

    # 切り替え
    io = StringIO.new
    CLI_Cdstk.execute(io, "setdb #{@work.path "db2"}".split)
    assert_match "Set default db", io.string

    # リセット
    io = StringIO.new
    assert_not_equal @first_default_dir, Dbdir.default_dir
    CLI_Cdstk.execute(io, "setdb --reset".split)
    assert_equal @first_default_dir, Dbdir.default_dir
  end

  def teardown
    @work.teardown
  end
end
