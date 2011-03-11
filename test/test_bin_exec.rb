# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/03/08

require 'rubygems'
require 'test/unit'
require File.join(File.dirname(__FILE__), "../lib/cdstk/cli")
require File.join(File.dirname(__FILE__), "../lib/cdview/cli")
require File.join(File.dirname(__FILE__), "../lib/cdweb/cli")

class TestBinExec < Test::Unit::TestCase
  def test_bin_exec
    io = StringIO.new

    CodeStock::CLI.execute(io)

    Grendb::CLI.execute(io)

    # 一定時間だけ起動するような仕組みは無いものか
    # Grenweb::CLI.execute(io, "--no-browser -p 5555".split)

    # puts io.string
  end
end




