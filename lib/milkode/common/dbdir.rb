# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/03/08

require 'fileutils'

module Milkode
  module Dbdir
    module_function

    @@milkode_db_dir = File.expand_path('~/.milkode_db_dir')

    def milkode_db_dir
      @@milkode_db_dir
    end

    def set_milkode_db_dir(dir)
      @@milkode_db_dir = dir
    end

    def default_dir
      path = @@milkode_db_dir

      if (File.exist? path)
        File.read path
      elsif (ENV['MILKODE_DEFAULT_DIR'])
        File.expand_path ENV['MILKODE_DEFAULT_DIR']
      else
        File.expand_path '~/.milkode'
      end
    end

    def groonga_path(path = '.')
      (Pathname.new(path) + 'db/milkode.db').to_s
    end

    def expand_groonga_path(path = '.')
      File.expand_path groonga_path(path)
    end
    
    def yaml_path(path = '.')
      (Pathname.new(path) + 'milkode.yaml').to_s
    end

    def dbdir?(path = '.')
      FileTest.exist? yaml_path(path)
    end

    def select_dbdir
      if (Dbdir.dbdir?('.') || !Dbdir.dbdir?(Dbdir.default_dir))
        '.'
      else
        Dbdir.default_dir
      end
    end
  end
end

