# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/xx/xxxx

require 'test_helper'
require 'milkode/database/groonga_database'
require 'milkode/cdstk/package.rb'

module Milkode
  class TestPackageTable < Test::Unit::TestCase
    def test_database
      begin
        t_setup
        t_open
        t_packages
        t_packages_viewtime
        t_sort
        t_yaml_sync
        t_touch
      ensure
        t_cleanup
      end
    end

    def t_setup
      @obj = GroongaDatabase.new
      @tmp_dir = File.join(File.dirname(__FILE__), "groonga_database_work")
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
      @packages = @obj.packages
      # @obj.close
    end

    def t_packages
      # @obj.open(@tmp_dir)

      packages = @obj.packages
      assert_equal 0, packages.size

      packages.add("milkode")
      assert_equal 1, packages.size

      r = packages["milkode"]
      assert_equal "milkode", r.name
      assert r.addtime.to_i  > 0
      assert_equal 0, r.updatetime.to_i
      assert_equal 0, r.viewtime.to_i
      assert_equal 0, r.favtime.to_i

      packages.remove("milkode")
      assert_equal 0, packages.size
    end
    
    def t_packages_viewtime
      packages = @obj.packages
      packages.add("add")
      packages.add("update")
      packages.add("view")
      packages.add("favorite")
      assert_equal 4, packages.size

      packages.each do |r|
        # p r
      end

      r = packages["update"]
      r.updatetime = Time.now
      
      r = packages["view"]
      r.viewtime = Time.now

      r = packages["favorite"]
      r.favtime = Time.now
      
      # packages.dump

      assert_not_equal 0, packages["update"].updatetime
      assert_not_equal 0, packages["view"].viewtime
      assert_not_equal 0, packages["favorite"].favtime

      packages.remove_all
      assert_equal 0, packages.size
    end

    def t_sort
      packages = @obj.packages

      t = Time.now

      r = packages.add("r1")
      r.updatetime = t + 1
      r.viewtime = t + 2
      r.favtime = t + 3
      
      r = packages.add("r2")
      r.updatetime = t + 3
      r.viewtime = t + 1
      # r.favtime
      
      r = packages.add("r3")
      r.updatetime = t + 2
      r.viewtime = t + 3
      r.favtime = t + 2

      sorted = packages.sort("updatetime")
      assert_equal "r2", sorted[0].name 
      assert_equal "r3", sorted[1].name 
      assert_equal "r1", sorted[2].name 

      sorted = packages.sort("viewtime")
      assert_equal "r3", sorted[0].name 
      assert_equal "r1", sorted[1].name 
      assert_equal "r2", sorted[2].name 

      sorted = packages.sort("favtime")
      assert_equal "r1", sorted[0].name 
      assert_equal "r3", sorted[1].name 
      assert_equal "r2", sorted[2].name 

      # sorted.each do |r|
      #   p [r.name, r.addtime, r.updatetime, r.viewtime, r.favtime]
      # end

      packages.remove_all
    end

    def t_yaml_sync
      assert_equal 0, @obj.packages.size

      yaml_contents =
        [
         Package.create('/path/to/dir'), 
         Package.create('/path/to/d2'),
         Package.create('/path/to/d3', ["*.bak"])
        ]
      @obj.yaml_sync(yaml_contents)
      assert_equal 3, @obj.packages.size

      yaml_contents << Package.create('/path/to/d4')
      @obj.yaml_sync(yaml_contents)
      assert_equal 4, @obj.packages.size

      # @obj.packages.dump

      @obj.packages.remove_all
    end

    def t_touch
      r = @packages.add("r1")
      t = Time.now

      assert_not_equal t, r.updatetime
      assert_not_equal t, r.viewtime
      assert_not_equal t, r.favtime

      @packages.touch("r1", :updatetime, t)
      assert_equal t, r.updatetime

      @packages.touch("r1", :viewtime, t)
      assert_equal t, r.viewtime

      @packages.touch("r1", :favtime, t)
      assert_equal t, r.favtime

      @packages.remove_all
    end
  end
end
