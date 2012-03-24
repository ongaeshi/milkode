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
include Milkode

module Milkode
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

    def initialize
      open(Database.dbdir)
    end

    def yaml_reload
      # @yaml = YamlFileWrapper.load_if(@@db_dir || Dbdir.default_dir)
    end

    def open(db_dir)
      dbfile = Dbdir.expand_groonga_path(db_dir)
      
      if File.exist? dbfile
        Groonga::Database.open(dbfile)
      else
        raise "error    : #{dbfile} not found!!"
      end
      
      @documents = Groonga::Context.default["documents"]
    end

    def record(shortpath)
      table = @documents.select { |record| record.shortpath == shortpath }
      return table.records[0]
    end

    def search(patterns, packages, current_path, fpaths, suffixs, offset = 0, limit = -1)
      # パッケージ名から絶対パスに変換
      unless packages.empty?
        packages = convert_packages(packages)

        # キーワードがパッケージ名にマッチしなければ検索しない
        return [], 0 if packages.empty?
      else
        # パッケージ名未指定の時は現在位置もfpathsに含める
        fpaths << current_path + "/" unless current_path == ""
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
      reopen_patch
      @documents.select.size      
    end

    # yamlからパッケージの総数を得る
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
      
      # shortpathにマッチするものだけに絞り込む
      if (base == "")
        records = @documents.select.records
      else
        records = @documents.select {|record| record.shortpath =~ base }.to_a
      end

      # ファイルリストの生成
      paths = records.map {|record|
        record.shortpath.split("/")
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
    
    # 指定したfpathにマッチするレコードを削除する
    def remove_fpath(fpath)
      # データベースを開き直す
      reopen_patch
      
      # 削除したいコンテンツを検索
      records, total_records = searchMain([], [], [fpath], [], 0, -1)

      # 検索結果はHashのレコードなので、これを直接deleteしても駄目
      # 1. Record#record_idを使って主キー(Groonga#Arrayのレコード)を取り出し
      # 2. Record#delete で削除
      records.each do |r|
        yield r if block_given?
        r.record_id.delete
      end
    end

    # 実体の存在しないデータを削除
    def cleanup
      # データベースを開き直す
      reopen_patch

      # クリーンアップ
      records = selectAll2

      records.each do |r|
        unless File.exist? r.path
          yield r if block_given?
          r.record_id.delete
        end
      end
    end

    private 

    def reopen_patch
      # 削除系のコマンドが上手く動作しないためのパッチ
      # 本質的な解決にはなっていないと思う
      open(Database.dbdir)
    end

    def searchMain(patterns, packages, fpaths, suffixs, offset, limit)
      table = @documents.select do |record|
        expression = nil

        # キーワード
        patterns.each do |word|
          sub_expression = record.content =~ word
          if expression.nil?
            expression = sub_expression
          else
            expression &= sub_expression
          end
        end
        
        # パッケージ(OR)
        pe = package_expression(record, packages) 
        if (pe)
          if expression.nil?
            expression = pe
          else
            expression &= pe
          end
        end
        
        # ファイルパス
        fpaths.each do |word|
          sub_expression = record.path =~ word
          if expression.nil?
            expression = sub_expression
          else
            expression &= sub_expression
          end
        end

        # 拡張子(OR)
        se = suffix_expression(record, suffixs) 
        if (se)
          if expression.nil?
            expression = se
          else
            expression &= se
          end
        end
        
        # 検索式
        expression
      end

      # スコアとタイムスタンプでソート
      # records = table.sort([{:key => "_score", :order => "descending"},
      #                       {:key => "timestamp", :order => "descending"}],
      #                      :offset => offset,
      #                      :limit => limit)
      
      # ファイル名でソート
      records = table.sort([{:key => "shortpath", :order => "ascending"}],
                           :offset => offset,
                           :limit => limit)

      # マッチ数
      total_records = table.size
      
      return records, total_records
    end
    private :searchMain

    def package_expression(record, packages)
      sub = nil
      
      # @todo 専用カラム package が欲しいところ
      #       でも今でもpackageはORとして機能してるからいいっちゃいい
      packages.each do |word|
        e = record.path =~ word
        if sub.nil?
          sub = e
        else
          sub |= e
        end
      end

      sub
    end
    private :package_expression

    def suffix_expression(record, suffixs)
      sub = nil
      
      suffixs.each do |word|
        e = record.suffix =~ word
        if sub.nil?
          sub = e
        else
          sub |= e
        end
      end

      sub
    end
    private :suffix_expression
    
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
