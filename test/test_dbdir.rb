# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/03/08

require 'rubygems'
require 'test_helper'
require 'codestock/common/dbdir'
require 'file_test_utils'

class TestDbDir< Test::Unit::TestCase
  include CodeStock
  include FileTestUtils

  def test_db_default_dir
    ENV['MILKODE_DEFAULT_DIR'] = nil
    assert_equal File.expand_path('~/.codestock'), db_default_dir

    ENV['MILKODE_DEFAULT_DIR'] = "~/DummyDir"
    assert_equal File.expand_path("~/DummyDir"), db_default_dir

    ENV['MILKODE_DEFAULT_DIR'] = nil
    ENV['CODESTOCK_DEFAULT_DIRR'] = "~/DummyDir"
    assert_equal File.expand_path('~/.codestock'), db_default_dir
  end

  def test_is_dbdir
    assert_equal false, dbdir?

    FileUtils.touch "grendb.yaml"
    assert_equal true, dbdir?
    
    FileUtils.mkdir_p 'damadame'
    FileUtils.touch "damadame/grendb.yaml"
    assert_equal true, dbdir?('damadame')
    assert_equal false, dbdir?('damadameyo')
  end

  def test_db_groonga_path
    assert_equal 'db/grendb.db', db_groonga_path 
    assert_equal '../db/grendb.db', db_groonga_path('..') 
    assert_equal '/Users/MrRuby/db/grendb.db', db_groonga_path('/Users/MrRuby')
  end

  def test_db_expand_groonga_path
    assert_equal File.expand_path('./db/grendb.db'), db_expand_groonga_path
  end

  def test_db_yaml_path
    assert_equal 'grendb.yaml', db_yaml_path 
    assert_equal '../grendb.yaml', db_yaml_path('..') 
    assert_equal '/Users/MrRuby/grendb.yaml', db_yaml_path('/Users/MrRuby') 
  end
end




