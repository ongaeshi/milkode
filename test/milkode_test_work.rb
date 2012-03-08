# -*- coding: utf-8 -*-
#
# @file 
# @brief Milkodeテスト用のワーク領域確保
# @author ongaeshi
# @date 2011/12/14

require 'test_helper'
require 'rubygems'
require 'groonga'
require 'pathname'
require 'fileutils'
require 'milkode/cdstk/cdstk'
require 'milkode/common/dbdir'

class MilkodeTestWork
  def initialize(option = nil)
    @option = option

    create_tmp_dir

    if (@option[:default_db])
      @old_path = Dbdir.milkode_db_dir
      path = expand_path(".milkode_db_dir")
      Dbdir.set_milkode_db_dir path
      open(Dbdir.milkode_db_dir, "w") {|f| f.print expand_path("db1") }
    end

    init_db("db1")
  end

  def init_db(name)
    dbdir = expand_path(name)
    FileUtils.mkdir_p dbdir
    Dir.chdir(dbdir) { cdstk.init({}) }
  end

  def add_package(name, package_path)
    dbdir = expand_path(name)
    
    Dir.chdir(dbdir) do
      cdstk.add [package_path], {}
    end
  end

  def teardown
    FileUtils.rm_rf(@tmp_dir.to_s)
    Dbdir.set_milkode_db_dir @old_path if (@option[:default_db])
  end

  def path(path)
    File.join @tmp_dir.to_s, path
  end
  
  def expand_path(path)
    File.expand_path path(path)
  end

  def pwd
    cdstk.pwd({})
  end
  
  private
  
  def create_tmp_dir
    @tmp_dir = Pathname(File.dirname(__FILE__)) + "milkode_test_work"
    FileUtils.rm_rf(@tmp_dir.to_s)
    FileUtils.mkdir_p(@tmp_dir.to_s)
  end

  def cdstk
    Cdstk.new(StringIO.new, Dbdir.select_dbdir)
  end

end



