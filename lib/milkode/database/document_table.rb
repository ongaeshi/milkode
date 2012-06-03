# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/05/29

require 'kconv'

module Milkode
  class DocumentTable
    def initialize(table)
      @table = table
    end

    def size
      @table.size
    end

    # 指定ファイルをテーブルに追加
    #
    # @param filename ファイル名
    # @param shortpath データベースに表示する名前
    # 
    # @retval :newfile 新規追加
    # @retval :update  更新
    # @retval nil      更新無し
    #
    def add(filename, shortpath)
      path = Util::filename_to_utf8(filename) # データベースに格納する時のファイル名はutf8
      shortpath = Util::filename_to_utf8(shortpath)
      suffix = File.extname(path)
      timestamp = File.mtime(filename) # OSへの問い合わせは変換前のファイル名で

      unless @table[path]
        # 新規追加
        @table.add(path, 
                   :path => path,
                   :shortpath => shortpath,
                   :content => load_content(filename),
                   :timestamp => timestamp,
                   :suffix => suffix)
        return :newfile
      else
        # 更新
      end
    end

    def load_content(filename)
      Kconv.kconv(File.read(filename), Kconv::UTF8)
    end
    private :load_content

    # # shortpathの一致するレコードを取得
    # def shortpath(shortpath)
    #   result = @table.select { |record| record.shortpath == shortpath }
    #   return result.records[0]
    # end
    
    # # 指定したpathにマッチするレコードを削除する(完全一致)
    # def remove_path(path)
    #   @table[path].delete
    # end

    # # 実体の存在しないデータを削除
    # def cleanup
    #   # クリーンアップ
    #   records = selectAll2

    #   records.each do |r|
    #     unless File.exist? r.path
    #       yield r if block_given?
    #       # p r.shortpath
    #       r.record_id.delete
    #     end
    #   end
    # end

    # # 指定されたパッケージのクリーンアップ
    # def cleanup_package_name(package)
    #   # クリーンアップ対象のファイルを検索
    #   records, total_records = search([], [], package, [], [], 0, -1)

    #   # 存在しないファイルの削除
    #   records.each do |r|
    #     unless File.exist? r.path
    #       yield r if block_given?
    #       # p r.shortpath
    #       r.record_id.delete
    #     end
    #   end
    # end

    # # 複雑な検索
    # # 
    # # @param patterns .. マッチする行
    # # @param packages .. パッケージ名(OR)
    # # @param paths    .. ファイルパス(AND)
    # # @param suffixs  .. 拡張子
    # # @param offset   .. オフセット
    # # @param limit    .. 表示リミット
    # def search(patterns, packages, paths, suffixs, offset = 0, limit = -1)
    # end

    def each
      @table.select.each do |r|
        yield r
      end
    end

    def dump
      self.each do |r|
        p [r.path, r.shortpath, r.content, r.timestamp, r.suffix]
      end
    end
  end
end


