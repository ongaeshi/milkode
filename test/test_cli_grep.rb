# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/12/03

require 'milkode/grep/cli_grep.rb'
require 'test_helper'

class TestCLI_Grep < Test::Unit::TestCase
  def setup
    @work = MilkodeTestWork.new({:default_db => true})
    @work.add_package "db1", @work.expand_path("../data/a_project")
    @work.add_package "db1", @work.expand_path("../data/b_project")
  end

  def test_basic
    io = StringIO.new

    CLI_Grep.execute(io, "".split)
    CLI_Grep.execute(io, "test".split)
    CLI_Grep.execute(io, "-p a_project test".split)

    # puts io.string
  end

  def test_not_found_package
    io = StringIO.new
    CLI_Grep.execute(io, "-p c_project test".split)
    assert_match "fatal:", io.string
  end

  def teardown
    @work.teardown
  end
end




