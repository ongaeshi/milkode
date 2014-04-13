# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/05/29

require 'kconv'
require 'milkode/common/util'

module Milkode
  class DocumentTable
    def self.define_schema
      begin
        Groonga::Schema.define do |schema|
          schema.create_table("documents", :type => :hash) do |table|          
            table.string("path")
            table.string("package")
            table.string("restpath")
            table.text("content")
            table.time("timestamp")
            table.string("suffix")
          end

          schema.create_table("terms",
                              :type => :patricia_trie,
                              :key_normalize => true,
                              :default_tokenizer => "TokenBigramSplitSymbolAlphaDigit") do |table|
            table.index("documents.path", :with_position => true)
            table.index("documents.package", :with_position => true)
            table.index("documents.restpath", :with_position => true)
            table.index("documents.content", :with_position => true)
            table.index("documents.suffix", :with_position => true)
          end
        end
      rescue Groonga::Schema::ColumnCreationWithDifferentOptions
        puts <<EOF
WARNING: Milkode database is old. (Renewal at 1.4.0)
Can't get the new features. Please execute rebuild command.

  $ milk rebuild --all

EOF

        Groonga::Schema.define do |schema|
          schema.create_table("documents", :type => :hash) do |table|          
            table.string("path")
            table.string("package")
            table.string("restpath")
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
            table.index("documents.restpath", :with_position => true)
            table.index("documents.content", :with_position => true)
            table.index("documents.suffix", :with_position => true)
          end
        end
      end
    end

    # レコードをまとめて削除する
    #   過去の方法
    #     検索結果にマッチしたレコード等をまとめて削除
    #     削除前にインデックスを削除し、削除後にインデックスを再度追加してい
    #     大量のレコードを削除する場合に高速に動作する
    #
    #   現在の方法
    #     上記の方法がかえって遅くなったので元に戻す
    #     普通に速くなった気がする
    # 
    def remove_records(records, &block)
      # Groonga::Schema.define do |schema|
      #   schema.change_table("terms") do |table|
      #     table.remove_index("documents.path")
      #     table.remove_index("documents.package")
      #     table.remove_index("documents.restpath")
      #     table.remove_index("documents.content")
      #     table.remove_index("documents.suffix")
      #   end
      # end

      records.each do |record|
        yield record if block
        record.key.delete
      end

      # Groonga::Schema.define do |schema|
      #   schema.change_table("terms") do |table|
      #     table.index("documents.path", :with_position => true)
      #     table.index("documents.package", :with_position => true)
      #     table.index("documents.restpath", :with_position => true)
      #     table.index("documents.content", :with_position => true)
      #     table.index("documents.suffix", :with_position => true)
      #   end
      # end
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
    # @param restpath パッケージディレクトリ以下のパス名 -> 'src/Foo.hpp'
    # @param package_name パッケージ名(未指定の場合は Fie.basename(package_dir) )
    # 
    # @retval :newfile 新規追加
    # @retval :update  更新
    # @retval nil      タイムスタンプ比較により更新無し
    #
    def add(package_dir, restpath, package_name = nil)
      filename  = File.join(package_dir, restpath)           # フルパスの作成
      filename  = File.expand_path(filename)                 # 絶対パスに変換
      path      = Util.filename_to_utf8(filename)           # データベースに格納する時のファイル名はutf8
      package   = package_name || File.basename(package_dir)
      package   = Util.filename_to_utf8(package)
      restpath  = Util.filename_to_utf8(restpath)
      suffix    = File.extname(path).sub('.', "")
      timestamp = Util.truncate_nsec(File.mtime(filename)) # OSへの問い合わせは変換前のファイル名で

      record = @table[path]

      unless record
        # 新規追加
        @table.add(path, 
                   :path => path,
                   :package => package,
                   :restpath => restpath,
                   :content => load_content(filename),
                   :timestamp => timestamp,
                   :suffix => suffix)
        return :newfile
      else
        if (record.timestamp < timestamp)
          # 更新
          record.package   = package
          record.restpath = restpath
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

    def remove_match_path(path, &block)
      remove_records(search(:paths => [path]), &block)
    end

    def remove_all(&block)
      remove_records(@table.select, &block)
    end

    # shortpathの一致するレコードを取得
    def find_shortpath(shortpath)
      package, restpath = Util.divide_shortpath(shortpath)
      result = @table.select { |record| (record.package == package) & (record.restpath == restpath) }
      return result.records[0]
    end
    
    # 指定パス以下のファイルを全て取得
    def find_shortpath_below(shortpath)
      if (shortpath.nil? || shortpath.empty?)
        @table.select.records
      else
        package, restpath = Util.divide_shortpath(shortpath)

        if (restpath.nil? || restpath.empty?)
          @table.select { |record| record.package == package }.to_a
        else
          @table.select { |record| (record.package == package) & (record.restpath =~ restpath)}.to_a
        end
      end
    end
    
    # 実体の存在しないデータを削除
    def cleanup
      self.each do |r|
        unless File.exist? r.path
          yield r if block_given?
          # p r.restpath
          remove(r.path)
        end
      end
    end

    # 詳細検索
    # 
    # @param options 検索オプション、ハッシュで指定
    #  :patterns => マッチする行
    #  :keywords => 検索キーワード
    #  :paths    => ファイルパス(AND)
    #  :packages => パッケージ名(OR)
    #  :strict_packages => 厳密なパッケージ名(OR)
    #  :restpaths => 短縮パス(AND)
    #  :suffixs  => 拡張子
    #  :offset   => オフセット(default = 0)
    #  :limit    => 表示リミット(default = -1)
    def search_with_match(options)
      patterns = options[:patterns] || []
      keywords = options[:keywords] || []
      packages = options[:packages] || []
      strict_packages = options[:strict_packages] || []
      paths    = options[:paths]    || []
      restpaths = options[:restpaths]    || []
      suffixs  = options[:suffixs]  || []
      fpath_or_packages = options[:fpath_or_packages] || []
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
          sub_expression |= record.restpath =~ word
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
        
        # 厳密なパッケージ(OR)
        pe = strict_packages_expression(record, strict_packages) 
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
        restpaths.each do |word|
          sub_expression = record.restpath =~ word
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
        
        # ファイル名かパッケージ名
        fpath_or_packages.each do |word|
          sub_expression = record.restpath =~ word
          sub_expression |= record.package =~ word
          if expression.nil?
            expression = sub_expression
          else
            expression &= sub_expression
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
      records = Util.groonga_table_sort(result,
                                        [{:key => "package", :order => "ascending"},
                                         {:key => "restpath", :order => "ascending"}],
                                        :offset => offset,
                                        :limit => limit)

      # 検索結果のレコード(limitの影響を受ける), 総マッチ数(limitの影響を受けない), result(Groonga::Hash)
      return records, result.size, result
    end

    # マッチしたレコードのみを返す
    def search(options)
      records, match_total = search_with_match(options)
      records
    end

    def self.drilldown(result, column, num = nil)
      drilled = result.group(column).map {|record| [record.n_sub_records, record.key]}.sort_by {|a| a[0]}.reverse
      num ? drilled[0, num] : drilled
    end
    
    def select_all_sort_by_shortpath(offset = 0, limit = -1)
      result = @table.select

      # @todo ここが速度低下の原因？と思ったけど、ここは全て選択の部分だけか・・・

      # 2010/10/29 ongaeshi
      # 本当はこのようにgroongaAPIでソートしたいのだが上手くいかなかった
      #       # ファイル名順にソート
      #       records = table.sort([{:key => "shortpath", :order => "descending"}],
      #                            :offset => offset,
      #                            :limit => limit)

      # ソート
      if (limit != -1)
        records = result.records.sort_by{|record| DocumentRecord::shortpath(record).downcase }[offset, limit]
      else
        records = result.records.sort_by{|record| DocumentRecord::shortpath(record).downcase }[offset..limit]
      end

      return records, result.size
    end

    # 指定されたパッケージのクリーンアップ
    def cleanup_package_name(package_name, ignore_checker = nil)
      # クリーンアップ対象のファイルを検索
      result = @table.select { |record| record.package == package_name }

      # 存在しない＆無視ファイルの削除
      result.each do |r|
        if !File.exist?(r.path) || (ignore_checker && ignore_checker.ignore?("/#{r.restpath}"))
          yield r if block_given?
          # p r.restpath
          remove(r.path)
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
        p [r.path, r.package, r.restpath, r.content, r.timestamp, r.suffix]
      end
    end

    def to_a
      @table.to_a
    end

    def package_records(name)
      search(:strict_packages => [name])
    end

    private

    def load_content(filename)
      Util.load_content($stdout, filename)
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
    
    def strict_packages_expression(record, packages)
      sub = nil
      
      packages.each do |word|
        e = record.package == word
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
        e = record.suffix == word
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


