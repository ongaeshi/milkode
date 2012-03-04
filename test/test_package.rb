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
    p4 = Package.create('/path/to/dir', ["*.bak"])

    assert p1.same_name? p2.name
    assert !p1.same_name?(p3.name)
    assert p1.same_name? p4.name
  end

  def test_eql
    p1 = Package.create('/path/to/dir')
    p2 = Package.create('/path/to/dir')
    p3 = Package.create('/path/to/d2')
    p4 = Package.create('/path/to/dir', ["*.bak"])

    assert p1 == p2
    assert p1 != p3
    assert p1 != p4
  end

  def test_options
    p1 = Package.create('/path/to/dir')
    assert_equal({}, p1.options)
  end

  def test_set_options
    p = Package.create('/path/to/dir')

    options = p.options
    options[:no_auto_ignore] = true
    p.set_options options

    assert_equal({:no_auto_ignore => true}, p.options)
    # p p.hash
  end

end
