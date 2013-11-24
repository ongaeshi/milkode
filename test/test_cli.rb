# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/12/03

require 'milkode/cli.rb'
require 'test_helper'
require 'milkode_test_work'

class TestCLI < Test::Unit::TestCase
  def setup
    $stdout = @stringio = StringIO.new
    @first_default_dir = Dbdir.default_dir
    @work = MilkodeTestWork.new({:default_db => true})
    @work.add_package "db1", @work.expand_path("../data/a_project")
    @orig_stdout = $stdout
  end

  def teardown
    $stdout = @orig_stdout
    @work.teardown
  end

  def test_add
    # system("type git")
    command("add")
    assert_not_match /error/, command("add https://github.com/ongaeshi/emacs-milkode.git")
    assert_not_match /error/, command("add https://github.com/ongaeshi/emacs-milkode.git -n em-develop -b develop")
    assert_match     /error/, command("add https://github.com/ongaeshi/emacs-milkode.git -n em-developa -b developa") # not found branch
  end

  def test_grep
    command("grep")
    command("grep not_found")
    command("grep require -a")
  end

  def test_mcd
    assert_match /mcd/, command("mcd")
  end

  def test_info
    # assert_match /.*packages.*records/, command("info")
    assert_match /Not registered/, command("info")
  end

  def test_setdb_no_arg_disp
    assert_equal @work.expand_path("db1") + "\n", command("setdb")
  end

  def test_setdb_milkode_db_dir_rewrite
    open(@work.path(".milkode_db_dir"), "w") {|f| f.print "/a/custom/db" }
    assert_equal "/a/custom/db\n", command("setdb")
  end

  def test_setdb_error_not_database_dir
    assert_match(/fatal:/, command("setdb /a/write/test"))
  end

  def test_setdb_change
    @work.init_db("db2")
    assert_match "Set default db", command("setdb #{@work.path "db2"}")
  end

  def test_setdb_reset
    assert_not_equal @first_default_dir, Dbdir.default_dir
    command("setdb --reset")
    assert_equal @first_default_dir, Dbdir.default_dir
  end

  def test_fav
    command("fav")
    command("fav a_not_found_package_xxxxxxx")
    @stringio.string = ""
    # command("fav package")
    # command("fav -d package")
    assert_equal "", command("fav --sync-yaml")
  end

  def test_help_with_h_option
    commands = ["init", "add", "update", "remove", "list", "pwd", "cleanup", "rebuild", "dump", "dir", "setdb", "mcd", "info", "ignore", "web", "fav"]
    commands.each do |cmd|
      assert_match "Usage:", command("#{ cmd } -h")
    end
  end

  def test_files
    command("files")
    command("files -r")
  end
  
  private

  def command(arg)
    CLI.start(arg.split)
    $stdout.string
  end
end
