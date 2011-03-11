# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'rubygems'
require 'groonga'
require File.join(File.dirname(__FILE__), "test_helper.rb")
require File.join(File.dirname(__FILE__), "file_test_utils")
require File.join(File.dirname(__FILE__), "../lib/cdstk/cli.rb")
require File.join(File.dirname(__FILE__), "../lib/cdstk/mkgrendb")
require 'stringio'

class TestMkgrendb < Test::Unit::TestCase
  include Mkgrendb
  include FileTestUtils

   def test_create
     db_path = Pathname.new('.') + 'db'
     database = Groonga::Database.create(:path => db_path.to_s)
     assert_equal database, Groonga::Context.default.database
   end

   def test_mkgrendb
     io = StringIO.new
     obj = Mkgrendb.new(io)
    
     # Mkgrendb#init
     obj.init
     assert_equal <<EOF, io.string
create     : grendb.yaml
create     : db/grendb.db created.
EOF
     
     io.string = ""
     obj.init
     assert_match "Can't create Grendb Database (Not empty)", io.string
     
     # Mkgrendb#add, remove
     obj.add('test1.html', 'test2.html')

     f1 = File.expand_path 'test1.html'
     f2 = File.expand_path 'test2.html'

     assert_equal [f1, f2], GrendbYAML.load.directorys
     assert_match /WARNING.*test1.html/, io.string
     assert_match /WARNING.*test2.html/, io.string

     obj.remove(f1, f2)
     assert_equal [], GrendbYAML.load.directorys
     
     # Mkgrendb#add
     io.string = ""
     obj.add('../../lib/findgrep', '../../lib/common')
     assert_match /add_file\s+:\s+.*findgrep.rb/, io.string
     assert_match /add_file\s+:\s+.*grenfiletest.rb/, io.string

     # Mkgrendb#update
     io.string = ""
     obj.update
  end

   def test_mkgrendb_other_path
     io = StringIO.new
     FileUtils.mkdir 'other_path'
     obj = Mkgrendb.new(io, 'other_path')
    
     # Mkgrendb#init
     obj.init
     assert_equal <<EOF, io.string
create     : other_path/grendb.yaml
create     : other_path/db/grendb.db created.
EOF
     
     io.string = ""
     obj.init
     assert_match "Can't create Grendb Database (Not empty)", io.string
     
     # Mkgrendb#add, remove
     obj.add('test1.html', 'test2.html')

     f1 = File.expand_path 'test1.html'
     f2 = File.expand_path 'test2.html'
     assert_equal [f1, f2], GrendbYAML.load('other_path').directorys
     assert_match /WARNING.*test1.html/, io.string
     assert_match /WARNING.*test2.html/, io.string

     obj.remove(f1, f2)
     assert_equal [], GrendbYAML.load('other_path').directorys
     
     # Mkgrendb#add
     io.string = ""
     obj.add('../../lib/findgrep', '../../lib/common')
     assert_match /add_file\s+:\s+.*findgrep.rb/, io.string
     assert_match /add_file\s+:\s+.*grenfiletest.rb/, io.string

     # Mkgrendb#update
     io.string = ""
     obj.update
  end

  def test_cli
    io = StringIO.new
    CLI.execute(io, ["init"])

    io.string = ""
    CLI.execute(io, ["add", "dummy/bar", "foo"])
    assert_match /dummy\/bar/, io.string
    assert_match /foo/, io.string
    
    io.string = ""
    CLI.execute(io, ["list"])
    assert_match /dummy\/bar/, io.string
    assert_match /foo/, io.string

    CLI.execute(io, ["remove", "foo"])
    io.string = ""
    CLI.execute(io, ["list"])
    assert_match /dummy\/bar/, io.string
    assert_no_match /foo/, io.string

    CLI.execute(io, ["update"])
    CLI.execute(io, ["rebuild"])
  end

  def test_dump
    io = StringIO.new
    CLI.execute(io, ["init"])
    CLI.execute(io, ["add", "../runner.rb"])
    io.string = ""
    CLI.execute(io, ["dump"])
    lines = io.string.split("\n")
    assert_match /path : .*test\/runner.rb/, lines[2]
    assert_match /shortpath : runner.rb/, lines[3]
    assert_match /suffix : \.rb/, lines[4]
  end

  def test_add_remove_compact
    io = StringIO.new

    CLI.execute(io, ["init"])
    CLI.execute(io, ["add", "dummy/bar"])
    CLI.execute(io, ["add", "dummy/bar"])

    assert_equal 1, GrendbYAML.load.directorys.select{|i|i == File.expand_path("dummy/bar")}.count
    
    CLI.execute(io, ["add", "dummy/da"])
    CLI.execute(io, ["add", "dummy/ad"])
    CLI.execute(io, ["add", "dummy/foo"])
    CLI.execute(io, ["add", "dummy/bar"])

    assert_equal 1, GrendbYAML.load.directorys.select{|i|i == File.expand_path("dummy/bar")}.count
  end

  def teardown
    teardown_custom(true)
#    teardown_custom(false)
  end
end


