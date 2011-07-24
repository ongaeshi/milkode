# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/03/08

require 'rubygems'
require 'test/unit'
require 'codestock/cdstk/cli_cdstk'
require 'codestock/cdview/cli_cdview'

class TestBinExec < Test::Unit::TestCase
  def test_bin_exec
    io = StringIO.new

    CodeStock::CLI_Cdstk.execute(io)
    
    CodeStock::CLI_Cdview.execute(io)

    # 一定時間だけ起動するような仕組みは無いものか
    # CodeStock::CLI_Cdweb.execute(io, "--no-browser -p 5555".split)
    
    # puts io.string
  end
end




