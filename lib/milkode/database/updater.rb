# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/09/15

require 'milkode/database/groonga_database'

module Milkode
  class Updater
    def initialize(grndb, package_name)
      @grndb = grndb
      @package_name = package_name
      @package = @grndb.packages[@package_name]
    end

    def exec
      # cleanup
      @grndb.documents.cleanup_package_name(@package_name)
      
      # update
      # Cdstk#update_dir_in

      # 更新時刻の更新
      @grndb.packages.touch(@package_name, :updatetime)
    end

    private
  end
end


