# -*- coding: utf-8 -*-
#
# @file 
# @brief Milkodeテスト用のワーク領域確保
# @author ongaeshi
# @date 2011/12/14

require 'test_helper'
require 'rubygems'
require 'groonga'

class MilkodeTestWork
  def initialize(option = nil)
    p option
  end

  def add_db(name)
    p name
  end

  def add_package(name, package_path)
    p name, package_path
  end

  def teardown
  end
end



