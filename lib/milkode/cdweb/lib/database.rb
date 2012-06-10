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
      DocumentRecord.create @documents.get_shortpath(shortpath)
    end

    def search(patterns, packages, current_path, fpaths, suffixs, offset = 0, limit = -1)
      # パッケージ名から絶対パスに変換
      unless packages.empty?
        packages = convert_packages(packages)

        # キーワードがパッケージ名にマッチしなければ検索しない
        return [], 0 if packages.empty?
      else
        # パッケージ名未指定の時は現在位置もfpathsに含める
        if current_path != ""
          fpaths << path2fpath(current_path)
        end
      end
      
      # @todo fpathを厳密に検索するには、検索結果からさらに先頭からのパスではないものを除外する
      records, total_records = searchMain(patterns, packages, fpaths, suffixs, offset, limit)
    end

    def selectAll(offset = 0, limit = -1)
      table = @documents.select

      # マッチ数
      total_records = table.size
      
      # @todo ここが速度低下の原因？と思ったけど、ここは全て選択の部分だけか・・・

      # 2010/10/29 ongaeshi
      # 本当はこのようにgroongaAPIでソートしたいのだが上手くいかなかった
      #       # ファイル名順にソート
      #       records = table.sort([{:key => "shortpath", :order => "descending"}],
      #                            :offset => offset,
      #                            :limit => limit)

      # ソート
      if (limit != -1)
        records = table.records.sort_by{|record| record.shortpath.downcase }[offset, limit]
      else
        records = table.records.sort_by{|record| record.shortpath.downcase }[offset..limit]
      end

      return records, total_records
    end

    def selectAll2(offset = 0, limit = -1)
      records, total_records = selectAll(offset, limit)
      records
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
      records = @documents.get_shortpath_below(base)

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
    
    private 

    def path2fpath(path)
      pa = path.split("/")
      File.join(convert_packages([pa[0]])[0], pa[1..-1].join('/'))
    end

    def convert_packages(packages)
      packages.inject([]) {|r, p| r += expand_packages(p)}
    end

    def expand_packages(keyword)
      yaml_load.match_all(keyword).map{|p| p.directory}
    end

    def yaml_load
      YamlFileWrapper.load_if(Database.dbdir)
    end

    # --- error ---
    class NotFoundPackage < RuntimeError ; end
  end
end
