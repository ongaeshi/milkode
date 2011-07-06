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
require 'cdstk/cdstk'
require 'codestock/cdweb/lib/database'

module CodeStock
  class TestDatabase < Test::Unit::TestCase
    include FileTestUtils

    def setup_db
      # データベース作成
      io = StringIO.new
      obj = Cdstk.new(io)
      obj.init
      obj.add('../../test')
      obj.add('../../lib')
      # puts io.string

      # データベースのセットアップ
      Database.setup('.')
    end

    def test_database
      setup_db
      t_open
      t_fileList
    end

    def t_open
      Database.instance
    end

    def t_fileList
      db = Database.instance
      
      assert_equal [['test', false], ['lib', false]], db.fileList('')
      assert_equal ['test/test_database.rb', true],   db.fileList('test')[6]
      assert_equal ['lib/cdstk', false],              db.fileList('lib')[0]
      assert_equal ['lib/cdstk/cdstk.rb', true],      db.fileList('lib/cdstk')[0]
      assert_equal nil,                               db.fileList('lib/cdstk/cdstk.rb')[0]
    end
  end
end


