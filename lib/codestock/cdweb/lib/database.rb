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
require 'codestock/common/dbdir'
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
    
    def search(patterns, packages, fpaths, suffixs, offset = 0, limit = -1)
      # @todo fpathを厳密に検索するには、検索結果からさらに先頭からのパスではないものを除外する
      records, total_records = searchMain(patterns, packages, fpaths, suffixs, offset, limit)
    end

    def selectAll(offset = 0, limit = -1)
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
      @documents.select.size      
    end

    # @sample test/test_database.rb:43 TestDatabase#t_fileList
    def fileList(base)
      base_parts = base.split("/")
      base_depth = base_parts.length
      
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
      }.uniq
      
      paths
    end
    
    # コンテンツの削除
    def remove(packages, io = nil)
      # 削除したコンテンツをインデックスから削除
      records, total_records = search([], packages, [], [])

      # 検索結果はHashのレコードなので、これを直接deleteしても駄目
      # 1. Record#record_idを使って主キー(Groonga#Arrayのレコード)を取り出し
      # 2. Record#delete で削除
      records.each do |r|
        io.puts r.shortpath if io
        r.record_id.delete
      end
    end

    # 実体の存在しないデータを削除
    def cleanup(io = nil)
      records = selectAll2

      records.each do |r|
        unless File.exist? r.path
          io.puts r.shortpath if io
          r.record_id.delete
        end
      end
    end
    
    private 

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
      records = table.sort([{:key => "_score", :order => "descending"},
                            {:key => "timestamp", :order => "descending"}],
                           :offset => offset,
                           :limit => limit)
      
      # パッケージの条件追加
      if (packages.size > 0)
        records.delete_if do |record|
          !packages.any?{|package| record.shortpath.split('/')[0] =~ /#{package}/ }
        end
      end

      # マッチ数
      total_records = records.size
      
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
