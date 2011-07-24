# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/03/08

require 'rubygems'
require 'test_helper'
require 'milkode/common/dbdir'
require 'file_test_utils'

class TestDbDir< Test::Unit::TestCase
  include CodeStock
  include FileTestUtils

  def test_default_dir
    ENV['MILKODE_DEFAULT_DIR'] = nil
    assert_equal File.expand_path('~/.milkode'), Dbdir.default_dir

    ENV['MILKODE_DEFAULT_DIR'] = "~/DummyDir"
    assert_equal File.expand_path("~/DummyDir"), Dbdir.default_dir

    ENV['MILKODE_DEFAULT_DIR'] = nil
    ENV['CODESTOCK_DEFAULT_DIRR'] = "~/DummyDir"
    assert_equal File.expand_path('~/.milkode'), Dbdir.default_dir
  end

  def test_is_dbdir
    assert_equal false, Dbdir.dbdir?

    FileUtils.touch "milkode.yaml"
    assert_equal true, Dbdir.dbdir?
    
    FileUtils.mkdir_p 'damadame'
    FileUtils.touch "damadame/milkode.yaml"
    assert_equal true, Dbdir.dbdir?('damadame')
    assert_equal false, Dbdir.dbdir?('damadameyo')
  end

  def test_groonga_path
    assert_equal 'db/milkode.db', Dbdir.groonga_path 
    assert_equal '../db/milkode.db', Dbdir.groonga_path('..') 
    assert_equal '/Users/MrRuby/db/milkode.db', Dbdir.groonga_path('/Users/MrRuby')
  end

  def test_expand_groonga_path
    assert_equal File.expand_path('./db/milkode.db'), Dbdir.expand_groonga_path
  end

  def test_yaml_path
    assert_equal 'milkode.yaml', Dbdir.yaml_path 
    assert_equal '../milkode.yaml', Dbdir.yaml_path('..') 
    assert_equal '/Users/MrRuby/milkode.yaml', Dbdir.yaml_path('/Users/MrRuby') 
  end
end




