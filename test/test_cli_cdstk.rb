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
require 'milkode_test_work'

class TestCLI_Cdstk < Test::Unit::TestCase
  def setup
    @first_default_dir = Dbdir.default_dir
    @work = MilkodeTestWork.new({:default_db => true})
    @work.add_package "db1", @work.expand_path("../data/a_project")
  end

  def test_main
    t_grep
    t_mcd
    t_setdb
    t_info
  end

  def teardown
    @work.teardown
  end

  private

  def t_grep
    command("grep")
    command("grep not_found")
    command("grep require -a")
  end

  def t_mcd
    assert_match /mcd/, command("mcd")
  end
  
  def t_info
    assert_match /.*packages.*records/, command("info")
  end
  
  def t_setdb
    # 引数無しで現在の値を表示
    assert_equal @work.expand_path("db1") + "\n", command("setdb")
    
    # .milkode_db_dir を書き換えてテスト
    open(@work.path(".milkode_db_dir"), "w") {|f| f.print "/a/custom/db" }
    assert_equal "/a/custom/db\n", command("setdb")

    # データベースではないディレクトリに切り替ようとするとエラー
    assert_match(/fatal:/, command("setdb /a/write/test"))
    
    # 切り替え
    @work.init_db("db2")
    assert_match "Set default db", command("setdb #{@work.path "db2"}")

    # リセット
    assert_not_equal @first_default_dir, Dbdir.default_dir
    command("setdb --reset")
    assert_equal @first_default_dir, Dbdir.default_dir
  end

  private

  def command(arg)
    io = StringIO.new
    CLI_Cdstk.execute(io, arg.split)
    io.string
  end
end
