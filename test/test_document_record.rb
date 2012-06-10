# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/xx/xxxx

require 'test_helper'
require 'milkode/database/groonga_database'
require 'milkode/database/document_table'
require 'milkode/database/document_record'
require 'fileutils'

module Milkode
  class TestDocumentTable < Test::Unit::TestCase
    def test_database
      begin
        t_setup
        t_open
        t_read
      ensure
        t_cleanup
      end
    end

    # -----------------------------------------------
    private

    def t_setup
      @obj = GroongaDatabase.new
      @tmp_dir = expand("groonga_database_work")
      @b_project = expand('data/b_project')
      @c_project = expand('data/c_project')
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

    def t_read
      @documents.add(@c_project, 'a.txt')
      @documents.add(@c_project, 'b.txt')

      result = @documents.search(:restpaths => ['a.txt'])

      r = DocumentRecord.new(result[0])
      assert_equal 'c_project', r.package
      assert_equal 'a.txt', r.restpath
      assert_equal 'c_project/a.txt', r.shortpath
      assert_equal '.txt', r.suffix
      # p r

      @documents.remove_all
    end

    # -----------------------------------------------

    def expand(path)
      File.expand_path(File.join(File.dirname(__FILE__), path))
    end
  end
end
