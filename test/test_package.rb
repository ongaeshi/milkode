# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'test_helper'
require 'milkode/cdstk/package.rb'

class TestPackage < Test::Unit::TestCase
  include Milkode

  def test_same_name?
    p1 = Package.create('/path/to/dir')
    p2 = Package.create('/path/to/dir')
    p3 = Package.create('/path/to/d2')

    assert p1.same_name? p2
    assert !p1.same_name?(p3)
  end

end
