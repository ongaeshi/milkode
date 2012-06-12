# -*- coding: utf-8 -*-
#
# @file 
# @brief  Milkodeで使用するデータベース
# @author ongaeshi
# @date   2010/10/17

require 'rubygems'
require 'pathname'
require 'singleton'
require 'groonga'
require 'milkode/common/dbdir'
require 'milkode/cdstk/yaml_file_wrapper'
require 'milkode/database/groonga_database'
include Milkode

module Milkode
  # @todo データベースアクセスは将来的にはGroongaDatabaseに収束させる
  class Database
    include Singleton

    @@db_dir = nil

    def self.setup(db_dir)
      @@db_dir = db_dir
    end

    def self.dbdir
      @@db_dir || Dbdir.default_dir
    end

    attr_reader :yaml
    attr_reader :grndb

    def initialize
      open
    end

    def yaml_reload
      # @yaml = YamlFileWrapper.load_if(@@db_dir || Dbdir.default_dir)
    end

    def open
      if !@grndb || @grndb.closed?
        @grndb = GroongaDatabase.new
        @grndb.open(Database.dbdir)
        @grndb.yaml_sync(yaml_load.contents)
        @documents = @grndb.documents
      end
    end

    def record(shortpath)
      DocumentRecord.create @documents.find_shortpath(shortpath)
    end

    def search(patterns, packages, current_path, fpaths, suffixs, offset = 0, limit = -1)
      # パッケージ名未指定の時は現在位置を検索条件に追加
      if packages.empty? && current_path != ''
        package, restpath = Util::divide_shortpath(current_path)
        packages << package
        fpaths << restpath if restpath
      end

      # 検索
      result = @documents.search(
        :patterns  => patterns,
        # :keywords  => ,
        # :paths     => ,
        :packages  => packages,
        :restpaths => fpaths,
        :suffixs   => suffixs,
        :offset    => offset,
        :limit     => limit,
      )

      # 結果
      return result.map{|r| DocumentRecord.new(r)}, result.size
    end

    def selectAll(offset, limit)
      @documents.select_all_sort_by_shortpath(offset, limit)
    end

    # レコード数を得る
    def totalRecords
      @documents.size
    end

    # yamlからパッケージの総数を得る
    # @todo PackageTableから取得するように変更する
    def yaml_package_num
      yaml_load.contents.size
    end
    
    # @sample test/test_database.rb:43 TestDatabase#t_fileList
    def fileList(base)
      base_parts = base.split("/")
      base_depth = base_parts.length

      # 'depth==0'の時はMilkodeYaml#contentsからファイルリストを生成して高速化
      if (base_depth == 0)
        return yaml_load.contents.sort_by{|v| v.name}.map{|v| [v.name, false] }
      end

      # base/以下のファイルを全て取得
      records = @documents.find_shortpath_below(base)

      # ファイルリストの生成
      paths = records.map {|record|
        DocumentRecord.new(record).shortpath.split("/")
      }.find_all {|parts|
        parts.length > base_depth and parts[0, base_depth] == base_parts
      }.map {|parts|
        is_file = parts.length == base_depth + 1
        path = parts[0, base_depth + 1].join("/")
        [path, is_file]
      }.sort_by {|parts|
        [if parts[1] then 1 else 0 end, parts[0].downcase]
      }.uniq
      
      paths
    end

    def packages(sort_kind)
      sorted = nil

      if (sort_kind)
        sorted = @grndb.packages.sort(sort_kind)
      else
        sorted = @grndb.packages.sort("name", "ascending")
      end

      sorted.map {|r| r.name}
    end

    def touch_viewtime(path)
      package, restpath = Util::divide_shortpath(path)
      @grndb.packages.touch(package, :viewtime) if package
    end
    
    private 

    def yaml_load
      YamlFileWrapper.load_if(Database.dbdir)
    end

  end
end
