# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/12/03

require 'milkode/cdstk/cli_cdstk.rb'
require 'milkode/common/dbdir'
require 'test_helper'
require 'file_test_utils'

class TestCLI_Cdstk < Test::Unit::TestCase
  include FileTestUtils

  def test_setdb
    path = File.expand_path(".milkode_db_dir")
    
    Dbdir.tmp_milkode_db_dir(path) do
      @first_default_dir = Dbdir.default_dir
      t_read(path)
      t_write(path)
      t_reset(path)
    end
  end

  private

  def t_read(path)
    # 引数無しで現在の値を表示
    io = StringIO.new
    CLI_Cdstk.execute(io, "setdb".split)
    # assert_equal "ENV['MILKODE_DEFAULT_DIR']", io.string  # 環境によって異なる
    
    # .milkode_db_dir を書き換えてテスト
    io = StringIO.new
    open(path, "w") {|f| f.print "/a/custom/db" }
    CLI_Cdstk.execute(io, "setdb".split)
    assert_equal "/a/custom/db\n", io.string
  end

  def t_write(path)
    io = StringIO.new
    CLI_Cdstk.execute(io, "setdb /a/write/test".split)
    io = StringIO.new
    CLI_Cdstk.execute(io, "setdb".split)
    assert_equal "/a/write/test\n", io.string
    
    io = StringIO.new
    CLI_Cdstk.execute(io, "setdb relative/path/test".split)
    io = StringIO.new
    CLI_Cdstk.execute(io, "setdb".split)
    assert_match /relative\/path\/test/, io.string
  end

  def t_reset(path)
    io = StringIO.new
    CLI_Cdstk.execute(io, "setdb --reset".split)
    assert_equal @first_default_dir, Dbdir.default_dir
  end
end




