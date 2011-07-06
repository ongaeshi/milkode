# -*- coding: utf-8 -*-
#
# @file 
# @brief  CodeStockで使用するデータベース
# @author ongaeshi
# @date   2010/10/17

require 'rubygems'
require 'pathname'
require 'singleton'
require 'groonga'
require 'common/dbdir'
include CodeStock

module CodeStock
  class Database
    include Singleton

    @@db_dir = nil

    def self.setup(db_dir)
      @@db_dir = db_dir
    end

    def initialize
      open(@@db_dir || db_default_dir)
    end

    def open(db_dir)
      dbfile = db_expand_groonga_path(db_dir)
      
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

    def fileNum
      @documents.select.size
    end

    def search(patterns, packages, fpaths, suffixs, page = 0, limit = -1)
      # 全てのパターンを検索
      if (fpaths.include?("*"))
        records, total_records = selectAll(page, limit)
      else
        records, total_records = searchMain(patterns, packages, fpaths, suffixs, page, limit)
      end

      # 結果
      return records, total_records
    end

    def selectAll(page, limit)
      table = @documents.select

      # マッチ数
      total_records = table.size

      # 2010/10/29 ongaeshi
      # 本当はこのようにgroongaAPIでソートしたいのだが上手くいかなかった
      #       # ファイル名順にソート
      #       records = table.sort([{:key => "shortpath", :order => "descending"}],
      #                            :offset => page * limit,
      #                            :limit => limit)
      
      # ソート
      records = table.records.sort_by{|record| record.shortpath.downcase }[page * limit, limit]

      return records, total_records
    end

    # @sample test/test_database.rb:43 TestDatabase#t_fileList
    def fileList(base)
      # match file
      if record(base)
        return [[base, true]]
      end
      
      # search dirs
      base_parts = base.split("/")
      base_depth = base_parts.length
      
      paths = @documents.select.records.map {|record|
        record.shortpath.split("/")
      }.find_all {|parts|
        parts.length > base_depth and parts[0, base_depth] == base_parts
      }.map {|parts|
        file_p = parts.length == base_depth + 1
        [parts[0, base_depth + 1].join("/"), file_p]
      }.uniq

      paths
    end

    private 

    def searchMain(patterns, packages, fpaths, suffixs, page, limit)
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

      # マッチ数
      total_records = table.size
      
      # スコアとタイムスタンプでソート
      records = table.sort([{:key => "_score", :order => "descending"},
                            {:key => "timestamp", :order => "descending"}],
                           :offset => page * limit,
                           :limit => limit)

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
    
  end
end
