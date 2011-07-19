# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'rubygems'
require 'groonga'
require 'test_helper'
require 'file_test_utils'
require 'codestock/cdstk/cli_cdstk.rb'
require 'codestock/cdstk/cdstk'
require 'stringio'

class TestCdstk < Test::Unit::TestCase
  include CodeStock
  include FileTestUtils

   def test_create
     db_path = Pathname.new('.') + 'db'
     database = Groonga::Database.create(:path => db_path.to_s)
     assert_equal database, Groonga::Context.default.database
   end

   def test_mkgrendb
     io = StringIO.new
     obj = Cdstk.new(io)
    
     # Cdstk#init
     obj.init
     assert_equal <<EOF, io.string
create     : grendb.yaml
create     : db/grendb.db created.
EOF
     
     io.string = ""
     obj.init
     assert_match "Can't create Grendb Database (Not empty)", io.string
     
     # Cdstk#add, remove
     obj.add('test1.html', 'test2.html')

     f1 = File.expand_path 'test1.html'
     f2 = File.expand_path 'test2.html'

     assert_equal [f1, f2], CdstkYaml.load.directorys
     assert_match /WARNING.*test1.html/, io.string
     assert_match /WARNING.*test2.html/, io.string

     obj.remove(f1, f2)
     assert_equal [], CdstkYaml.load.directorys
     
     # Cdstk#add
     io.string = ""
     obj.add('../../lib/codestock/findgrep', '../../lib/codestock/common')
     assert_match /add_file\s+:\s+.*findgrep.rb/, io.string
     assert_match /add_file\s+:\s+.*grenfiletest.rb/, io.string

     # Cdstk#update
     io.string = ""
     obj.update
  end

   def test_mkgrendb_other_path
     io = StringIO.new
     FileUtils.mkdir 'other_path'
     obj = Cdstk.new(io, 'other_path')
    
     # Cdstk#init
     obj.init
     assert_equal <<EOF, io.string
create     : other_path/grendb.yaml
create     : other_path/db/grendb.db created.
EOF
     
     io.string = ""
     obj.init
     assert_match "Can't create Grendb Database (Not empty)", io.string
     
     # Cdstk#add, remove
     obj.add('test1.html', 'test2.html')

     f1 = File.expand_path 'test1.html'
     f2 = File.expand_path 'test2.html'
     assert_equal [f1, f2], CdstkYaml.load('other_path').directorys
     assert_match /WARNING.*test1.html/, io.string
     assert_match /WARNING.*test2.html/, io.string

     obj.remove(f1, f2)
     assert_equal [], CdstkYaml.load('other_path').directorys
     
     # Cdstk#add
     io.string = ""
     obj.add('../../lib/codestock/findgrep', '../../lib/codestock/common')
     assert_match /add_file\s+:\s+.*findgrep.rb/, io.string
     assert_match /add_file\s+:\s+.*grenfiletest.rb/, io.string

     # Cdstk#update
     io.string = ""
     obj.update
  end

  def test_cli
    io = StringIO.new
    CLI_Cdstk.execute(io, ["init"])

    io.string = ""
    CLI_Cdstk.execute(io, ["add", "dummy/bar", "foo"])
    assert_match /dummy\/bar/, io.string
    assert_match /foo/, io.string
    
    io.string = ""
    CLI_Cdstk.execute(io, ["list"])
    assert_match /dummy\/bar/, io.string
    assert_match /foo/, io.string

    CLI_Cdstk.execute(io, ["remove", "foo"])
    io.string = ""
    CLI_Cdstk.execute(io, ["list"])
    assert_match /dummy\/bar/, io.string
    assert_no_match /foo/, io.string

    CLI_Cdstk.execute(io, ["update"])
    CLI_Cdstk.execute(io, ["rebuild"])
  end

  def test_dump
    io = StringIO.new
    CLI_Cdstk.execute(io, ["init"])
    CLI_Cdstk.execute(io, ["add", "../runner.rb"])
    io.string = ""
    CLI_Cdstk.execute(io, ["dump"])
    lines = io.string.split("\n")
    assert_match /path : .*test\/runner.rb/, lines[2]
    assert_match /shortpath : runner.rb/, lines[3]
    assert_match /suffix : \.rb/, lines[4]
  end

  def test_add_remove_compact
    io = StringIO.new

    CLI_Cdstk.execute(io, ["init"])
    CLI_Cdstk.execute(io, ["add", "dummy/bar"])
    CLI_Cdstk.execute(io, ["add", "dummy/bar"])

    assert_equal 1, CdstkYaml.load.directorys.select{|i|i == File.expand_path("dummy/bar")}.count
    
    CLI_Cdstk.execute(io, ["add", "dummy/da"])
    CLI_Cdstk.execute(io, ["add", "dummy/ad"])
    CLI_Cdstk.execute(io, ["add", "dummy/foo"])
    CLI_Cdstk.execute(io, ["add", "dummy/bar"])

    assert_equal 1, CdstkYaml.load.directorys.select{|i|i == File.expand_path("dummy/bar")}.count
  end

  def teardown
    teardown_custom(true)
#    teardown_custom(false)
  end
end


