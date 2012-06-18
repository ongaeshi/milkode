# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/05/28

require 'rubygems'
require 'groonga'
require 'milkode/common/dbdir'
require 'fileutils'
require 'milkode/database/package_table.rb'
require 'milkode/database/document_table.rb'
require 'milkode/database/document_record.rb'

module Milkode
  class GroongaDatabase
    def initialize
      @database = nil
    end

    # ディレクトリを指定して開く
    def open(base_dir)
      open_file Dbdir.groonga_path(base_dir)
    end

    # データベースファイルを指定して開く
    def open_file(filename)
      if File.exist?(filename)
        @database = Groonga::Database.open(filename)
        compatible?(filename)
        define_schema
      else
        FileUtils.mkdir_p(File.dirname filename)
        @database = Groonga::Database.create(:path => filename)
        define_schema
      end

      @packages = nil
      @documents = nil

      if block_given?
        begin
          yield self
        ensure
          close unless closed?
        end
      end
    end

    # あらかじめ GroongaDatabase#open しておく必要がある
    def yaml_sync(yaml_contents)
      yaml_contents.each do |yp|
        packages.add(yp.name, yp.directory) if packages[yp.name].nil?
      end
    end

    def close
      @database.close
      @database = nil
    end

    def closed?
      @database.nil? or @database.closed?
    end

    def documents
      @documents ||= DocumentTable.new(Groonga["documents"])
    end

    def packages
      @packages ||= PackageTable.new(Groonga["packages"])
    end

    def compatible?(filename, no_exit = nil)
      unless Groonga["documents"] && Groonga["packages"]
        unless no_exit
          puts <<EOF
Milkode repository is old -> #{filename}.
Please rebuild repository, 

  milk rebuild --all

See 'milk --help' or http://milkode.ongaeshi.me .
EOF
          exit -1
        else
          nil
        end
      else
        true
      end
    end
    
    private

    def define_schema
      DocumentTable.define_schema
      PackageTable.define_schema
    end

  end
end


