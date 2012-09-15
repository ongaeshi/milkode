# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/09/15

require 'milkode/database/groonga_database'
require 'milkode/common/grenfiletest'

module Milkode
  class Updater
    def initialize(grndb, package_name)
      @grndb = grndb
      @package_name = package_name
      @package = @grndb.packages[@package_name]

      @file_count = 0
      @add_count = 0
      @update_count = 0
    end

    def exec
      # cleanup
      @grndb.documents.cleanup_package_name(@package_name)
      
      # update
      update_dir(@package.directory)

      # 更新時刻の更新
      @grndb.packages.touch(@package_name, :updatetime)
    end

    private

    def update_dir(dir)
      if (FileTest.directory? dir)
        db_add_dir(dir)
      else
        db_add_file(STDOUT, File.dirname(dir), File.basename(dir), File.basename(dir)) # .bashrc/.bashrc のようになる
      end
    end

    def db_add_dir(dir)
      # @current_package = @yaml.package_root(dir)
      @current_ignore = IgnoreChecker.new
      # @current_ignore.add IgnoreSetting.new("/", @current_package.ignore) # 手動設定
      searchDirectory(STDOUT, dir, @package_name, "/", 0)
    end

    def db_add_file(stdout, package_dir, restpath, package_name = nil)
      # サイレントモード
      return if @is_silent

      # データベースには先頭の'/'を抜いて登録する
      #   最初から'/'を抜いておけば高速化の余地あり?
      #   ignore設定との互換性保持が必要
      restpath = restpath.sub(/^\//, "")

      # パッケージ名を設定
      package_name = package_name || File.basename(package_dir)

      # レコードの追加
      result = @grndb.documents.add(package_dir, restpath, package_name)

      # メッセージの表示
      case result
      when :newfile
        @add_count += 1
        # alert_info("add_record", File.join(package_dir, restpath))
      when :update
        # @grndb.packages.touch(package_name, :updatetime)
        @update_count += 1
        # alert_info("update", File.join(package_dir, restpath))
      end
    end

    def searchDirectory(stdout, dirname, packname, path, depth)
      # 現在位置に.gitignoreがあれば無視設定に加える
      # add_current_gitignore(dirname, path) unless @current_package.options[:no_auto_ignore]

      # 子の要素を追加
      Dir.foreach(File.join(dirname, path)) do |name|
        next if (name == '.' || name == '..')

        next_path = File.join(path, name)
        fpath     = File.join(dirname, next_path)
        shortpath = File.join(packname, next_path)

        # 除外ディレクトリならばパス
        next if ignoreDir?(fpath, next_path)

        # 読み込み不可ならばパス
        next unless FileTest.readable?(fpath)

        # ファイルならば中身を探索、ディレクトリならば再帰
        case File.ftype(fpath)
        when "directory"
          searchDirectory(stdout, dirname, packname, next_path, depth + 1)
        when "file"
          unless ignoreFile?(fpath, next_path)
            db_add_file(stdout, dirname, next_path) # shortpathの先頭に'/'が付いているのが気になる
            @file_count += 1
            # @out.puts "file_count : #{@file_count}" if (@file_count % 100 == 0)
          end
        end
      end
    end

    def ignoreDir?(fpath, mini_path)
      FileTest.directory?(fpath) &&
        (GrenFileTest::ignoreDir?(fpath) ||
         package_ignore?(fpath, mini_path))
    end

    def ignoreFile?(fpath, mini_path)
      GrenFileTest::ignoreFile?(fpath) ||
        GrenFileTest::binary?(fpath) ||
        package_ignore?(fpath, mini_path)
    end

    def package_ignore?(fpath, mini_path)
      if @current_ignore.ignore?(mini_path)
        # alert_info("ignore", fpath)
        true
      else
        false
      end
    end


  end
end


