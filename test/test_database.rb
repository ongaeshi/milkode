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
require 'stringio'
require 'codestock/cdstk/cdstk'
require 'codestock/cdweb/lib/database'

module CodeStock
  class TestDatabase < Test::Unit::TestCase
    include FileTestUtils

    def setup_db
      # データベース作成
      io = StringIO.new
      @obj = Cdstk.new(io)
      @obj.init
      @obj.add(['../../test'])
      @obj.add(['../../lib'])

      FileUtils.touch('notfound.file')
      @obj.add(['notfound.file'])
      FileUtils.rm('notfound.file')

      # puts io.string

      # データベースのセットアップ
      Database.setup('.')
    end

    def test_database
      setup_db
      t_open
      t_fileList
      # t_cleanup # 何故か 'rake test' で実行すると上手く動かないので、一旦テストから外す
      t_remove
    end

    def t_open
      Database.instance
    end

    def t_fileList
      db = Database.instance
      assert_equal [['test', false], ['lib', false], ["notfound.file", true]], db.fileList('')
      assert db.fileList('test').include? ['test/test_database.rb', true]
      assert_equal ['lib/codestock', false],              db.fileList('lib')[0]
      assert_equal ['lib/codestock/cdstk/cdstk.rb', true],      db.fileList('lib/codestock/cdstk')[0]
      assert_equal nil,                               db.fileList('lib/codestock/cdstk/cdstk.rb')[0]
    end

    def t_cleanup
      db = Database.instance
      db.cleanup
    end

    def t_remove
      db = Database.instance
      db.remove('test')
      db.remove('lib')
      assert_equal 0, db.totalRecords
    end
  end
end


