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
require 'milkode/common/util'
require 'milkode/database/updater'
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
        open_force
      end
    end

    def open_force
      @grndb = GroongaDatabase.new
      @grndb.open(Database.dbdir)
      @grndb.yaml_sync(yaml_load.contents)
      @documents = @grndb.documents
    end

    def record(shortpath)
      DocumentRecord.create @documents.find_shortpath(shortpath)
    end

    def search(patterns, keywords, packages, current_path, fpaths, suffixs, fpath_or_packages, offset = 0, limit = -1)
      paths = []
      strict_packages = []
      is_not_search = false

      # パッケージ名未指定の時は現在位置を検索条件に追加
      if packages.empty? && current_path != ''
        package, restpath = Util::divide_shortpath(current_path)

        grn_package = @grndb.packages[package]
        if grn_package
          # パッケージ名
          strict_packages << package

          # ファイルパス
          directory = grn_package.directory
          if restpath
            paths << File.join(directory, restpath)
          else
            paths << directory
          end

        else
          is_not_search = true
        end
      end

      # 検索
      result, total_records = [], 0

      begin
        unless is_not_search
          result, total_records = @documents.search_with_match(
            :patterns  => patterns,
            :keywords  => keywords,
            :paths     => paths,
            :packages  => packages,
            :strict_packages  => strict_packages,
            :restpaths => fpaths,
            :suffixs   => suffixs,
            :fpath_or_packages => fpath_or_packages,
            :offset    => offset,
            :limit     => limit
          )
        end
      rescue Groonga::TooLargeOffset
      end

      # 結果
      return result.map{|r| DocumentRecord.new(r)}, total_records
    end

    def selectAll(offset, limit)
      @documents.select_all_sort_by_shortpath(offset, limit)
    end

    # レコード数を得る
    def totalRecords
      @documents.size
    end

    # 指定パッケージに属する全てのレコードを得る
    def package_records(name)
      @documents.package_records(name)
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
        # 先頭フォルダ名が一致するものをピックアップ
        parts.length > base_depth && parts[0, base_depth] == base_parts
      }.map {|parts|
        # [path, is_file]
        [parts[0, base_depth + 1].join("/"), parts.length == base_depth + 1]
      }.sort_by {|parts|
        # 配列の比較を利用したディレクトリ優先ソート
        # aaa, bbb/, aaa/, bbb -> [aaa/, bbb/, aaa, bbb]
        [parts[1] ? 1 : 0, parts[0].downcase] # [is_file(int), path(downcase)]
      }.uniq
      
      paths
    end

    def packages(sort_kind)
      sorted = nil

      if sort_kind == "favtime"
        sorted = @grndb.packages.favs
      elsif (sort_kind)
        sorted = @grndb.packages.sort(sort_kind)
      else
        # 大文字／小文字を無視してソートするため、速度を犠牲に
        # sorted = @grndb.packages.sort("name", "ascending")
        sorted = @grndb.packages.to_a.sort_by {|r| r.name.downcase}        
      end

      sorted.map {|r| r.name}
    end

    def touch_viewtime(path)
      package, restpath = Util::divide_shortpath(path)
      @grndb.packages.touch_if(package, :viewtime) if package
    end

    def fav?(name)
      @grndb.packages.fav?(name)
    end

    def set_fav(name, favorited)
      time = favorited ? Time.now : Time.at(0)
      @grndb.packages.touch_if(name, :favtime, time)
    end

    def update(name)
      result = Updater::ResultAccumulator.new
      result << update_in(yaml_load.find_name(name))
      result
    end

    def update_all
      result = Updater::ResultAccumulator.new
      yaml_load.contents.each do |package|
        result << update_in(package)
      end
      result
    end

    def self.validate?
      YamlFileWrapper.load_if(Database.dbdir) != nil
    end
    
    private 

    def yaml_load
      YamlFileWrapper.load_if(Database.dbdir)
    end

    def update_in(package)
      updater = Updater.new(@grndb, package.name)

      yaml = yaml_load
      
      updater.set_global_gitignore(yaml.global_gitignore) if yaml.global_gitignore
      updater.set_package_ignore IgnoreSetting.new("/", package.ignore)
      updater.enable_no_auto_ignore         if package.options[:no_auto_ignore]
      
      updater.enable_update_with_git_pull   if package.options[:update_with_git_pull]
      updater.enable_update_with_svn_update if package.options[:update_with_svn_update]
      updater.enable_update_with_ctags      if package.options[:update_with_ctags]
      updater.enable_update_with_ctags_e    if package.options[:update_with_ctags_e]

      updater.exec
      updater.result
    end

  end
end
