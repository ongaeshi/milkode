# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/03/08

require 'fileutils'

module CodeStock
  DEFAULT_PATH = '~/.codestock'
  
  def db_default_dir
    if (ENV['MILKODE_DEFAULT_DIR'])
      File.expand_path ENV['MILKODE_DEFAULT_DIR']
    else
      File.expand_path DEFAULT_PATH
    end
  end

  def dbdir?(path = '.')
    FileTest.exist? db_yaml_path(path)
  end

  def db_groonga_path(path = '.')
    (Pathname.new(path) + 'db/grendb.db').to_s
  end

  def db_expand_groonga_path(path = '.')
    File.expand_path db_groonga_path(path)
  end

  def db_yaml_path(path = '.')
    (Pathname.new(path) + 'grendb.yaml').to_s
  end
end

