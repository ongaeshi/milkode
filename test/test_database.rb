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
require 'milkode/cdstk/cdstk'
require 'milkode/cdstk/package'
require 'milkode/cdweb/lib/database'

module Milkode
  class TestDatabase < Test::Unit::TestCase
    include FileTestUtils

    def setup_db
      # データベース作成
      io = StringIO.new
      @obj = Cdstk.new(io)
      @obj.init({})

      @obj.add(['../../test'], {})

      FileUtils.touch('../../lib/delete_on.cleanup_package_name')
      @obj.add(['../../lib'], {})
      FileUtils.rm('../../lib/delete_on.cleanup_package_name')

      FileUtils.touch('notfound.file')
      @obj.add(['notfound.file'], {})
      FileUtils.rm('notfound.file')

      # puts io.string

      # データベースのセットアップ
      Database.setup('.')

      # yamlファイルのリロード
      Database.instance.yaml_reload
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
      assert_equal [['lib', false], ["notfound.file", false], ['test', false]], db.fileList('')
      assert db.fileList('test').include? ['test/test_database.rb', true]
      assert_equal ['lib/milkode', false],              db.fileList('lib')[0]
      assert_equal ['lib/milkode/cdstk/cdstk.rb', true],      db.fileList('lib/milkode/cdstk')[0]
      assert_equal nil,                               db.fileList('lib/milkode/cdstk/cdstk.rb')[0]
    end

    def teardown
      teardown_custom(true)
      # teardown_custom(false)
    end
  end
end


