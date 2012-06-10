# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/xx/xxxx

require 'test_helper'
require 'milkode/database/groonga_database'
require 'milkode/common/dbdir'
require 'milkode/cdstk/package.rb'
require 'fileutils'

module Milkode
  class TestDocumentTable < Test::Unit::TestCase
    def test_database
      begin
        t_setup
        t_open
        t_documents
        t_remove
        t_shortpath
        t_grndb_cleanup
        t_search
        t_search2
        t_search_packages
        t_search_paths
        t_search_suffixs
        t_search_keywords
        t_cleanup_package_name
        t_remove_match_path
        t_add_package_name
        t_shortpath_below
      ensure
        t_cleanup
      end
    end

    def t_setup
      @obj = GroongaDatabase.new
      @tmp_dir = expand("groonga_database_work")
      @b_project = expand('data/b_project')
      @c_project = expand('data/c_project')
    end

    def expand(path)
      File.expand_path(File.join(File.dirname(__FILE__), path))
    end
    
    def t_cleanup
      # 本当は明示的にcloseした方が行儀が良いのだけれど、
      # 単体テストの時にSementationFaultが出るのでコメントアウト
      # @obj.close

      # データベース削除
      @obj = nil
      FileUtils.rm_rf(@tmp_dir)

      # time.txt削除
      FileUtils.rm_f(File.join(@c_project, 'time.txt'))
    end

    def t_open
      @obj.open(@tmp_dir)
      @documents = @obj.documents
      # @obj.close
    end

    # -----------------------------------------------

    def t_documents
      documents = @obj.documents
      assert_equal 0, documents.size

      assert_equal :newfile, documents.add(@c_project, 'a.txt')
      assert_equal 1, documents.size

      assert_equal :newfile, documents.add(@c_project, 'b.txt')
      assert_equal 2, documents.size

      assert_equal nil, documents.add(@c_project, 'b.txt')
      assert_equal 2, documents.size

      # documents.dump

      # ファイルの作成
      current = Time.now
      touch(File.join(@c_project, 'time.txt'), current - 1)
      documents.add(@c_project, 'time.txt')
      assert_equal 3, documents.size

      # c_project/time.txt を現在時刻で書き換えて更新テスト
      touch(File.join(@c_project, 'time.txt'), current)
      assert_equal :update, documents.add(@c_project, 'time.txt')

      # documents.dump

      documents.remove_all
      assert_equal 0, documents.size
    end

    def t_remove
      documents = @obj.documents
      assert_equal :newfile, documents.add(@c_project, 'a.txt')
      assert_equal :newfile, documents.add(@c_project, 'b.txt')
      assert_equal 2, documents.size

      documents.remove(File.join(@c_project, 'a.txt'))
      assert_equal 1, documents.size
      # documents.dump

      documents.remove_all
    end

    def t_shortpath
      documents = @obj.documents
      documents.add(@c_project, 'a.txt')
      documents.add(@c_project, 'b.txt')
      documents.add(@c_project, 'time.txt')

      assert_equal 'b.txt', documents.get_shortpath('c_project/b.txt').restpath
      assert_equal 'time.txt', documents.get_shortpath('c_project/time.txt').restpath
      assert_nil documents.get_shortpath('c_project/c.txt')

      documents.remove_all
    end

    def t_grndb_cleanup
      documents = @obj.documents

      tmp_dir = expand("groonga_database_work")
      tmp_filename = File.join(tmp_dir, 'test.c')
      open(tmp_filename, "w") do |file|
        file.write(Time.now)
      end
      documents.add(tmp_dir, 'test.c')
      assert_equal 1, documents.size

      FileUtils.rm_f tmp_filename
      documents.cleanup
      assert_equal 0, documents.size

      documents.remove_all
    end

    def t_search
      @documents.add(@c_project, 'a.txt')
      @documents.add(@c_project, 'b.txt')
      @documents.add(@c_project, 'c.txt')
      @documents.add(@c_project, 'cc.txt')

      records = @documents.search(:patterns => ['a'])
      assert_equal 1, records.size
      assert_equal 'a.txt', records[0].restpath

      records = @documents.search(:patterns => ['b'])
      assert_equal 1, records.size
      assert_equal 'b.txt', records[0].restpath

      records = @documents.search(:patterns => ['c'])
      assert_equal 2, records.size
      assert_equal 'c.txt', records[0].restpath
      assert_equal 'cc.txt', records[1].restpath

      # @documents.dump

      @documents.remove_all
    end

    def t_search2
      @documents.add(@c_project, 'abc.c')
      @documents.add(@c_project, 'abc.h')

      records = @documents.search(:patterns => ['def', '456'])
      assert_equal 2, records.size

      records = @documents.search(:patterns => ['def', '123'])
      assert_equal 1, records.size

      # @documents.dump

      @documents.remove_all
    end

    def t_search_packages
      @documents.add(@c_project, 'abc.c')
      @documents.add(@b_project, 'runner.rb')

      records = @documents.search(:packages => ['b_project'])

      assert_equal 1, records.size
      assert_equal 'runner.rb', records[0].restpath

      @documents.remove_all
    end

    def t_search_paths
      @documents.add(@c_project, 'abc.c')
      @documents.add(@c_project, 'abc.h')

      records = @documents.search(:paths => ['abc'])
      assert_equal 2, records.size

      records = @documents.search(:restpaths => ['h'])
      assert_equal 1, records.size

      # @documents.dump

      @documents.remove_all
    end

    def t_search_suffixs
      @documents.add(@c_project, 'a.txt')
      @documents.add(@c_project, 'b.txt')
      @documents.add(@c_project, 'abc.c')
      @documents.add(@c_project, 'abc.h')

      records = @documents.search(:suffixs => ['c'])
      assert_equal 1, records.size

      records = @documents.search(:suffixs => ['h'])
      assert_equal 1, records.size

      records = @documents.search(:suffixs => ['h', 'c'])
      assert_equal 2, records.size

      records = @documents.search(:suffixs => ['txt'])
      assert_equal 2, records.size

      # @documents.dump

      @documents.remove_all
    end

    def t_search_keywords
      @documents.add(@c_project, 'a.txt')
      @documents.add(@c_project, 'b.txt')
      @documents.add(@c_project, 'abc.c')
      @documents.add(@c_project, 'abc.h')

      records = @documents.search(:keywords => ['txt'])
      assert_equal 2, records.size

      records = @documents.search(:keywords => ['a'])
      assert_equal 3, records.size

      records = @documents.search(:keywords => ['project'])
      assert_equal 4, records.size

      @documents.remove_all
    end

    def t_cleanup_package_name
      @documents.add(@c_project, 'a.txt')
      add_and_remove(@c_project, 'time.txt')
      add_and_remove(@b_project, 'time.txt')

      @documents.cleanup_package_name('c_project')
      assert_equal 2, @documents.size

      @documents.cleanup_package_name('b_project')
      assert_equal 1, @documents.size

      @documents.remove_all
    end

    def t_remove_match_path
      @documents.add(@c_project, 'a.txt')
      @documents.add(@c_project, 'b.txt')
      @documents.add(@b_project, 'runner.rb')

      @documents.remove_match_path(@c_project)
      assert_equal 1, @documents.size

      @documents.remove_all
    end

    def t_add_package_name
      @documents.add(@c_project, 'a.txt', 'other_package')
      @documents.add(@c_project, 'b.txt')

      assert_equal nil, @documents.get_shortpath('c_project/a.txt')
      assert_equal 'other_package', @documents.get_shortpath('other_package/a.txt').package
      assert_equal 'c_project', @documents.get_shortpath('c_project/b.txt').package

      @documents.remove_all
    end

    def t_shortpath_below
      @documents.add(@c_project, 'a.txt')
      @documents.add(@c_project, 'b.txt')
      @documents.add(@c_project, 'to/file.rb')
      @documents.add(@b_project, 'runner.rb')

      assert_equal 4, @documents.get_shortpath_below('').size
      assert_equal 3, @documents.get_shortpath_below('c_project').size
      assert_equal 1, @documents.get_shortpath_below('c_project/to').size
      assert_equal 1, @documents.get_shortpath_below('c_project/to/').size

      @documents.remove_all
    end

    private

    def touch(filename, timestamp)
      FileUtils.touch(filename, :mtime => timestamp)
      # open(filename, "w") {|dst| dst.write(Time.now) }
    end

    def add_and_remove(project_dir, restpath)
      tmp_filename = File.join(project_dir, restpath)
      touch(tmp_filename, Time.now)
      @documents.add(project_dir, restpath)
      FileUtils.rm_f tmp_filename
    end
  end
end
