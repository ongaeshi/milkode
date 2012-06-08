# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/05/29

require 'kconv'

module Milkode
  class DocumentTable
    def self.define_schema
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
      end
    end
    
    def initialize(table)
      @table = table
    end

    def size
      @table.size
    end

    # 指定ファイルをテーブルに追加
    #
    # @param package_dir パッケージディレクトリ -> '/path/to/Package'
    # @param shortpath パッケージディレクトリ以下のパス名 -> 'src/Foo.hpp'
    # 
    # @retval :newfile 新規追加
    # @retval :update  更新
    # @retval nil      タイムスタンプ比較により更新無し
    #
    def add(package_dir, shortpath)
      filename = File.join(package_dir, shortpath) # フルパスの作成
      filename = File.expand_path(filename) # 絶対パスに変換
      path = Util::filename_to_utf8(filename) # データベースに格納する時のファイル名はutf8
      package = Util::filename_to_utf8(File.basename(package_dir))
      shortpath = Util::filename_to_utf8(shortpath)
      suffix = File.extname(path)
      timestamp = File.mtime(filename) # OSへの問い合わせは変換前のファイル名で

      record = @table[path]

      unless record
        # 新規追加
        @table.add(path, 
                   :path => path,
                   :package => package,
                   :shortpath => shortpath,
                   :content => load_content(filename),
                   :timestamp => timestamp,
                   :suffix => suffix)
        return :newfile
      else
        if (record.timestamp < timestamp)
          # 更新
          record.package   = package
          record.shortpath = shortpath
          record.content   = load_content(filename)
          record.timestamp = timestamp
          record.suffix    = suffix
          return :update
        else
          # タイムスタンプ比較により更新無し
          return nil
        end
      end
    end

    def remove(name)
      @table[name].delete
    end

    def remove_match_path(path)
      result = search(:paths => [path])

      result.each do |r|
          yield r if block_given?
          r.record_id.delete
      end
    end

    def remove_all
      self.each do |r|
        r.record_id.delete
      end
    end

    # shortpathの一致するレコードを取得
    def shortpath(shortpath)
      result = @table.select { |record| record.shortpath == shortpath }
      return result.records[0]
    end
    
    # 実体の存在しないデータを削除
    def cleanup
      self.each do |r|
        unless File.exist? r.path
          yield r if block_given?
          # p r.shortpath
          r.record_id.delete
        end
      end
    end

    # 詳細検索
    # 
    # @param options 検索オプション、ハッシュで指定
    #  :patterns => マッチする行
    #  :packages => パッケージ名(OR)
    #  :paths    => ファイルパス(AND)
    #  :shortpaths => 短縮パス(AND)
    #  :suffixs  => 拡張子
    #  :offset   => オフセット(default = 0)
    #  :limit    => 表示リミット(default = -1)
    def search(options)
      patterns = options[:patterns] || []
      keywords = options[:keywords] || []
      packages = options[:packages] || []
      paths    = options[:paths]    || []
      shortpaths = options[:shortpaths]    || []
      suffixs  = options[:suffixs]  || []
      offset   = options[:offset]   || 0
      limit    = options[:limit]    || -1
      
      result = @table.select do |record|
        expression = nil

        # マッチする行
        patterns.each do |word|
          sub_expression = record.content =~ word
          if expression.nil?
            expression = sub_expression
          else
            expression &= sub_expression
          end
        end
        
        # キーワード(絞り込むための手がかり)
        keywords.each do |word|
          sub_expression = record.content =~ word
          sub_expression |= record.shortpath =~ word
          sub_expression |= record.package =~ word
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
        paths.each do |word|
          sub_expression = record.path =~ word
          if expression.nil?
            expression = sub_expression
          else
            expression &= sub_expression
          end
        end

        # 短縮パス
        shortpaths.each do |word|
          sub_expression = record.shortpath =~ word
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
      # records = result.sort([{:key => "_score", :order => "descending"},
      #                       {:key => "timestamp", :order => "descending"}],
      #                      :offset => offset,
      #                      :limit => limit)
      
      # ファイル名でソート
      records = result.sort([{:key => "shortpath", :order => "ascending"}],
                           :offset => offset,
                           :limit => limit)

      records
    end

    # 指定されたパッケージのクリーンアップ
    def cleanup_package_name(package)
      # クリーンアップ対象のファイルを検索
      records = search(:packages => [package])

      # 存在しないファイルの削除
      records.each do |r|
        unless File.exist? r.path
          yield r if block_given?
          # p r.shortpath
          r.record_id.delete
        end
      end
    end

    def each
      @table.select.each do |r|
        yield r
      end
    end

    def dump
      self.each do |r|
        p [r.path, r.package, r.shortpath, r.content, r.timestamp, r.suffix]
      end
    end

    private

    def load_content(filename)
      Kconv.kconv(File.read(filename), Kconv::UTF8)
    end

    def package_expression(record, packages)
      sub = nil
      
      packages.each do |word|
        e = record.package =~ word
        if sub.nil?
          sub = e
        else
          sub |= e
        end
      end

      sub
    end
    
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
  end
end


