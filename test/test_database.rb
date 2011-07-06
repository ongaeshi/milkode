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
      t_filelist
    end

    def t_open
      Database.instance
    end

    def t_filelist
      db = Database.instance
      
      assert_equal [['test', false], ['lib', false]], db.fileList('/')
      p db.fileList('/test')
      # assert_equal 'test_database.rb', db.fileList('/test')[5][0]
    end
  end
end


