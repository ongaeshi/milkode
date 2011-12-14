# -*- coding: utf-8 -*-
#
# @file 
# @brief cdstk command set (Only action, not display message.)
# @author ongaeshi
# @date   2011/12/12

require 'milkode/common/dbdir'

module Milkode
  class CdstkCommand
    def setdb_set(path)
      raise NotExistDatabase unless Dbdir.dbdir?(path)
      open(Dbdir.milkode_db_dir, "w") {|f| f.print path }
    end

    def setdb_reset
      FileUtils.rm_f(Dbdir.milkode_db_dir)
    end
    
    # --- error ---
    class NotExistDatabase < RuntimeError ; end
  end
end


