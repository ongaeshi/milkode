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

module Milkode
  class GroongaDatabase
    def initialize
      @database = nil
    end

    def open(base_dir)
      path = Dbdir.groonga_path(base_dir)

      if File.exist?(path)
        @database = Groonga::Database.open(path)
        define_schema
      else
        FileUtils.mkdir_p(File.dirname path)
        @database = Groonga::Database.create(:path => path)
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
        packages.add(yp.name) if packages[yp.name].nil?
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

    private

    def define_schema
      Groonga::Schema.define do |schema|
        schema.create_table("documents", :type => :hash) do |table|          
          table.string("path")
          table.string("package")
          table.string("shortpath")
          table.text("content")
          table.time("timestamp")
          table.text("suffix")
        end

        schema.create_table("terms",
                            :type => :patricia_trie,
                            :key_normalize => true,
                            :default_tokenizer => "TokenBigramSplitSymbolAlphaDigit") do |table|
          table.index("documents.path", :with_position => true)
          table.index("documents.package", :with_position => true)
          table.index("documents.shortpath", :with_position => true)
          table.index("documents.content", :with_position => true)
          table.index("documents.suffix", :with_position => true)
        end

        schema.create_table("packages", :type => :hash) do |table|
          table.string("name")
          table.time("addtime")
          table.time("updatetime")
          table.time("viewtime")
          table.time("favtime")
        end
      end
    end
  end
end


