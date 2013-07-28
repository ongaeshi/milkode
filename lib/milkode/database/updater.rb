# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/09/15

require 'milkode/database/groonga_database'
require 'milkode/common/grenfiletest'
require 'milkode/common/ignore_checker'
require 'kconv'

module Milkode
  class Updater
    attr_reader :result
    
    def initialize(grndb, package_name)
      @grndb          = grndb
      @package_name   = package_name
      @package        = @grndb.packages[@package_name]
      @result         = Result.new
      @current_ignore = IgnoreChecker.new
      @options        = {}
      @out            = $stdout
    end

    def exec
      # git pull
      if @options[:update_with_git_pull]
        Dir.chdir(@package.directory) { system("git pull") }        
      end
      
      # svn update
      if @options[:update_with_svn_update]
        Dir.chdir(@package.directory) { system("svn update") }
      end

      # Add global .gitignore
      if @options[:global_gitignore]
        add_global_gitignore(@options[:global_gitignore])
      end

      # update
      update_dir(@package.directory)

      # cleanup
      unless @options[:no_clean]
        @grndb.documents.cleanup_package_name(@package_name, @current_ignore)
      end
      
      # 更新時刻の更新
      @grndb.packages.touch(@package_name, :updatetime)
    end

    def set_package_ignore(ignore_setting)
      @current_ignore.add ignore_setting
    end

    def enable_no_auto_ignore
      @options[:no_auto_ignore] = true
    end

    def enable_silent_mode
      @options[:silent_mode] = true
    end

    def enable_display_info
      @options[:display_info] = true
    end

    def enable_update_with_git_pull
      @options[:update_with_git_pull] = true      
    end

    def enable_update_with_svn_update
      @options[:update_with_svn_update] = true
    end

    def enable_no_clean
      @options[:no_clean] = true      
    end

    def set_global_gitignore(filename)
      @options[:global_gitignore] = filename 
    end

    class Result
      attr_reader :file_count
      attr_reader :add_count
      attr_reader :update_count

      def initialize
        @file_count = 0
        @add_count = 0
        @update_count = 0
      end

      def inc_file_count
        @file_count += 1
      end

      def inc_add_count
        @add_count += 1
      end

      def inc_update_count
        @update_count += 1
      end
    end

    class ResultAccumulator
      attr_reader :package_count
      attr_reader :file_count
      attr_reader :add_count
      attr_reader :update_count

      def initialize
        @package_count = 0
        @file_count    = 0
        @add_count     = 0
        @update_count  = 0
      end
      
      def <<(result)
        @package_count += 1
        @file_count    += result.file_count
        @add_count     += result.add_count
        @update_count  += result.update_count
      end
    end
    
    # ---------------------------------------------------------
    private

    def update_dir(dir)
      if (!FileTest.exist?(dir))
        warning_alert("#{dir} (Not found, skip)")
      elsif (FileTest.directory? dir)
        db_add_dir(dir)
      else
        db_add_file(File.dirname(dir), File.basename(dir), File.basename(dir)) # .bashrc/.bashrc のようになる
      end
    end

    def db_add_dir(dir)
      searchDirectory(dir, @package_name, "/", 0)
    end

    def db_add_file(package_dir, restpath, package_name = nil)
      # サイレントモード
      return if @options[:silent_mode]

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
        @result.inc_add_count
        alert_info("add_record", File.join(package_dir, restpath))
      when :update
        # @grndb.packages.touch(package_name, :updatetime)
        @result.inc_update_count
        alert_info("update", File.join(package_dir, restpath))
      end
    end

    def searchDirectory(dirname, packname, path, depth)
      # 現在位置に.gitignoreがあれば無視設定に加える
      add_current_gitignore(dirname, path) unless @options[:no_auto_ignore]

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
          searchDirectory(dirname, packname, next_path, depth + 1)
        when "file"
          unless ignoreFile?(fpath, next_path)
            db_add_file(dirname, next_path) # shortpathの先頭に'/'が付いているのが気になる
            @result.inc_file_count
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
        alert_info("ignore", fpath)
        true
      else
        false
      end
    end

    def add_current_gitignore(dirname, path)
      filename = File.join(dirname, path, ".gitignore")
      
      if File.exist? filename
        alert_info("add_ignore", filename)
        str = Util::load_content($stdout, filename)
        @current_ignore.add IgnoreSetting.create_from_gitignore(path, str)
      end
    end

    def add_global_gitignore(filename)
      if File.exist? filename
        alert_info("add_ignore", filename)
        str = Util::load_content($stdout, filename)
        @current_ignore.add IgnoreSetting.create_from_gitignore("/", str)
      end
    end

    def alert_info(title, msg)
      alert(title, msg) if @options[:display_info]
    end

    def alert(title, msg)
      if (Util::platform_win?)
        @out.puts "#{title.ljust(10)} : #{Kconv.kconv(msg, Kconv::SJIS)}"
      else
        @out.puts "#{title.ljust(10)} : #{msg}"
      end
    end

    def warning_alert(msg)
      @out.puts "[warning] #{msg}"
    end

  end
end


