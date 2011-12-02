# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/12/03

require 'milkode/grep/cli_grep.rb'
require 'test_helper'

class TestCLI_Grep < Test::Unit::TestCase
  include Milkode
  
  def test_basic
    io = StringIO.new

    CLI_Grep.execute(io, [])
    CLI_Grep.execute(io, ['test'])

    # puts io.string
  end
end




