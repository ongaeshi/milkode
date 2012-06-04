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
      ensure
        t_cleanup
      end
    end

    def t_setup
      @obj = GroongaDatabase.new
      @tmp_dir = expand("groonga_database_work")
      @file_a = expand('data/c_project/a.txt')
      @file_b = expand('data/c_project/b.txt')
      @file_t = expand('data/c_project/time.txt')
    end

    def expand(path)
      File.join(File.dirname(__FILE__), path)
    end
    
    def t_cleanup
      # 本当は明示的にcloseした方が行儀が良いのだけれど、
      # 単体テストの時にSementationFaultが出るのでコメントアウト
      # @obj.close

      # データベース削除
      @obj = nil
      FileUtils.rm_rf(@tmp_dir)
    end

    def t_open
      @obj.open(@tmp_dir)
      # @obj.close
    end

    # -----------------------------------------------

    def t_documents
      documents = @obj.documents
      assert_equal 0, documents.size

      assert_equal :newfile, documents.add(@file_a, 'c_project/a.txt')
      assert_equal 1, documents.size

      assert_equal :newfile, documents.add(@file_b, 'c_project/b.txt')
      assert_equal 2, documents.size

      assert_equal nil, documents.add(@file_b, 'c_project/b.txt')
      assert_equal 2, documents.size

      # ファイルの作成
      current = Time.now
      touch(@file_t, current - 1)
      documents.add(@file_t, 'c_project/time.txt')
      assert_equal 3, documents.size

      # c_project/time.txt を現在時刻で書き換えて更新テスト
      touch(@file_t, current)
      assert_equal :update, documents.add(@file_t, 'c_project/time.txt')

      # documents.dump

      documents.remove_all
      assert_equal 0, documents.size
    end

    def t_remove
      documents = @obj.documents
      assert_equal :newfile, documents.add(@file_a, 'c_project/a.txt')
      assert_equal :newfile, documents.add(@file_b, 'c_project/b.txt')
      assert_equal 2, documents.size

      documents.remove(File.expand_path(@file_a))
      assert_equal 1, documents.size

      # documents.dump

      documents.remove_all
    end

    def t_shortpath
      documents = @obj.documents
      documents.add(@file_a, 'c_project/a.txt')
      documents.add(@file_b, 'c_project/b.txt')
      documents.add(@file_t, 'c_project/time.txt')

      assert_equal 'c_project/b.txt', documents.shortpath('c_project/b.txt').shortpath
      assert_equal 'c_project/time.txt', documents.shortpath('c_project/time.txt').shortpath
      assert_nil documents.shortpath('d_project/b.txt')

      documents.remove_all
    end

    def t_grndb_cleanup
      documents = @obj.documents

      tmp_filename = expand("groonga_database_work/test.c")
      open(tmp_filename, "w") do |file|
        file.write(Time.now)
      end
      documents.add(tmp_filename, 'test.c')
      assert_equal 1, documents.size

      FileUtils.rm_f tmp_filename
      documents.cleanup
      assert_equal 0, documents.size

      documents.remove_all
    end

    def touch(filename, timestamp)
      FileUtils.touch(filename, :mtime => timestamp)
      # open(filename, "w") {|dst| dst.write(Time.now) }
    end
  end
end