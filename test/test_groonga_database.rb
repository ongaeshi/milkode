# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/xx/xxxx

require 'test_helper'
require 'milkode/database/groonga_database'
require 'milkode/common/dbdir'

module Milkode
  class TestGroongaDatabase < Test::Unit::TestCase
    def test_open
      obj = GroongaDatabase.new

      tmp_dir = File.join(File.dirname(__FILE__), "groonga_database_work")

      obj.open(tmp_dir)

      packages = obj.packages
      assert_equal 0, packages.size

      # 本当は明示的にcloseした方が行儀が良いのだけれど、SementationFaultが出るのでコメントアウト
      # obj.close

      # データベース削除
      obj = nil
      FileUtils.rm_rf(tmp_dir)
    end
  end
end
