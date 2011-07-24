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

    def default_dir
      if (ENV['MILKODE_DEFAULT_DIR'])
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
  end
end

