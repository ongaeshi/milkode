# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/12/03

require 'milkode/grep/cli_grep.rb'
require 'test_helper'
require 'milkode_test_work'

class TestCLI_Grep < Test::Unit::TestCase
  def setup
    @work = MilkodeTestWork.new({:default_db => true})
    @work.add_package "db1", @work.expand_path("../data/a_project")
    @work.add_package "db1", @work.expand_path("../data/b_project")
  end

  def test_main
    # 全てを test_* にすると、毎回setup, teardown が走ってデータベースを生成する時間がもったいないので
    t_basic
    t_not_found_package
    t_not_package_root
  end

  def teardown
    @work.teardown
  end

  private

  def t_basic
    io = StringIO.new

    CLI_Grep.execute(io, "".split)
    CLI_Grep.execute(io, "-a test".split)
    CLI_Grep.execute(io, "-p a_project test".split)

    # io.puts
  end

  def t_not_found_package
    io = StringIO.new
    CLI_Grep.execute(io, "-p c_project test".split)
    assert_match "fatal:", io.string
  end

  def t_not_package_root
    Dir.chdir(File.join(File.dirname(__FILE__))) do
      io = StringIO.new
      CLI_Grep.execute(io, "require".split)
      assert_match "fatal:", io.string
    end
    
    Dir.chdir(File.join(File.dirname(__FILE__), "data/a_project")) do
      io = StringIO.new
      CLI_Grep.execute(io, "require".split)
      assert_no_match /fatal:/, io.string
    end
  end
end




