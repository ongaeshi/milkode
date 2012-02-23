# -*- coding: utf-8 -*-

require 'yaml'
require 'pathname'
require 'rubygems'
require 'groonga'
require 'fileutils'
require 'pathname'
require 'milkode/cdstk/cdstk_yaml'
require 'milkode/common/grenfiletest'
require 'milkode/common/util'
require 'milkode/common/dir'
include Milkode
require 'kconv'
begin
  require 'readline'
rescue LoadError
  $no_readline = true
end
require 'milkode/cdweb/lib/database'
require 'open-uri'

require 'milkode/cdstk/cdstk_command' # @todo 削除予定
require 'milkode/cdstk/yaml_file_wrapper'
require 'milkode/cdstk/package'

module Milkode
  class Cdstk
    # バイグラムでトークナイズする。連続する記号・アルファベット・数字は一語として扱う。
    # DEFAULT_TOKENIZER = "TokenBigram"

    # 記号・アルファベット・数字もバイグラムでトークナイズする。
    DEFAULT_TOKENIZER = "TokenBigramSplitSymbolAlphaDigit"

    class ConvetError < RuntimeError ; end
    
    def initialize(io = $stdout, db_dir = ".")
      @db_dir = db_dir
      Database.setup(@db_dir)
      @out = io
      # @out = $stdout # 強制出力
      @is_display_info = false     # alert_info の表示
      clear_count
      @yaml = YamlFileWrapper.load_if(@db_dir)
    end

    def clear_count
      @package_count = 0
      @file_count = 0
      @add_count = 0
      @update_count = 0
      @start_time = Time.now
    end

    def init(options)
      if Dir.emptydir?(@db_dir)
        @yaml = YamlFileWrapper.create(@db_dir)
        @out.puts "create     : #{yaml_file}"
        db_create(db_file)
        setdb([@db_dir], {}) if (options[:setdb])
      else
        @out.puts "Can't create milkode db (Because not empty in #{db_dir_expand})"
      end
    end

    def compatible?
      db_open(db_file)
    end

    def update_all
      print_result do 
        db_open(db_file)

        @yaml.contents.each do |package|
          update_dir_in(package.directory)
        end
      end
    end

    def update(args, options)
      update_display_info(options)
      
      if (options[:all])
        update_all
      else
        if (args.empty?)
          path = File.expand_path('.')
          package = @yaml.package_root(path)

          if (package)
            print_result do
              db_open(db_file)
              update_dir_in(package.directory)
            end
          else
            @out.puts "Not registered. If you want to add, 'milk add #{path}'."
          end
        else
          print_result do
            db_open(db_file)
            args.each do |name|
              package = @yaml.find_name(name)
              if (package)
                update_dir_in(package.directory)                
              else
                @out.puts "Not found package '#{name}'."
              end
            end
          end
        end
      end
    end

    def update_package(dir)
      db_open(db_file)
      update_dir(dir)
    end

    def update_dir(dir)
      update_dir_in(dir)
    end

    def add(dirs, options)
      update_display_info(options)

      begin
        dirs.each do |v|
          # コンテンツを読み込める形に変換
          dir = convert_content(v)

          # YAMLに追加
          add_yaml(Package.create(dir))
        end
      rescue ConvetError
        return
      end
      
      # 部分アップデート
      print_result do 
        db_open(db_file)
        dirs.each do |dir|
          update_dir(dir)
        end
      end
    end

    def add_dir(dir)
      add_yaml(Package.create(dir))
      db_open(db_file)
      update_dir(dir)
    end

    # yamlにパッケージを追加
    def add_yaml(package)
      # すでに同名パッケージがある
      if @yaml.find_name(package.name)
        error_alert("already exist '#{package.name}'.")
        return
      end

      # ファイルが存在しない
      unless File.exist?(package.directory)
        error_alert("not found '#{package.directory}'.")
        return
      end

      # YAML更新
      @yaml.add(package)
      @yaml.save
    end

    def convert_content(src)
      # httpファイルならダウンロード
      begin
        src = download_file(src)
      rescue => e
        error_alert("download failure '#{src}'.")
        raise e                 # そのまま上に持ち上げてスタックトレース表示
      end
      
      # アーカイブファイルなら展開
      begin
        src = extract_file(src)
      rescue => e
        error_alert("extract failure '#{src}'.")
        raise e                 # そのまま上に持ち上げてスタックトレース表示
      end

      # 絶対パスに変換
      File.expand_path(src)
    end

    def extract_file(src)
      ext = File.extname(src);
      
      case ext
      when '.zip', '.xpi'
        alert("extract", "#{src}")
        zip_dir = File.join(@db_dir, "packages/#{ext.sub(".", "")}")
        result = File.join(zip_dir, Util::zip_extract(src, zip_dir))
      else
        src
      end
    end

    def download_file(src)
      if (src =~ /^https?:/)
        download_file_in(src)
      else
        src
      end
    end

    def download_file_in(url)
      alert("download", "#{url}")
      
      dst_dir = File.join(@db_dir, "packages/http")
      FileUtils.mkdir_p dst_dir

      filename = File.join(dst_dir, File.basename(url))
      
      open(url) do |src|
        open(filename, "wb") do |dst|
          dst.write(src.read)
        end
      end

      filename
    end

    def remove_all
      print_result do
        list([], {:verbose => true})
        
        if yes_or_no("Remove #{@yaml.contents.size} contents? (yes/no)")
          db_open(db_file)

          @yaml.contents.each do |package|
            remove_dir(package.directory)
          end
        end
      end
    end

    def remove(args, options)
      update_display_info(options)
      
      if (options[:all])
        remove_all
      else
        if (args.empty?)
          path = File.expand_path('.')
          package = @yaml.package_root(path)

          if (package)
            print_result do
              db_open(db_file)
              remove_dir(package.directory)
            end
          else
            @out.puts "Not registered. '#{path}'."
          end
        else
          print_result do
            db_open(db_file)
            args.each do |name|
              package = @yaml.find_name(name)
              if (package)
                remove_dir(package.directory)                
              else
                @out.puts "Not found package '#{name}'."
              end
            end
          end
        end
      end
    end

    def yes_or_no(msg)
      if ($no_readline)
        @out.puts "Pass Cdstk#yes_or_no, because fail \"require 'readline'\"."
        return true
      end
        
      @out.puts msg
      while buf = Readline.readline("> ")
        case buf
        when 'yes'
          return true
        when 'no'
          break
        end
      end
      return false
    end

    def list(args, options)
      match_p = @yaml.contents.find_all do |p|
        args.all? {|k| p.name.include? k }
      end

      max = match_p.map{|p| p.name.length}.max

      str = match_p.sort_by {|p|
        p.name
      }.map {|p|
        h = File.exist?(p.directory) ? '' : '? '
        if (options[:verbose])
          "#{(h + p.name).ljust(max+2)} #{p.directory}"
        else
          "#{h}#{p.name}"
        end
      }.join("\n")

      @out.puts str

      # print information
      if args.empty?
        milkode_info
      else
        list_info(match_p) unless match_p.empty?
      end
    end

    def pwd(options)
      dir = options[:default] ? Dbdir.default_dir : db_dir_expand
      
      if File.exist? dir
        @out.puts dir
      else
        @out.puts "Not found db in #{Dir.pwd}"
      end
    end

    def cleanup(options)
      # 互換性テスト
      db_open(db_file)

      # cleanup開始
      if (options[:force] or yes_or_no("cleanup contents? (yes/no)"))
        print_result do 
          # yamlファイルのクリーンアップ
          yaml = yaml_load
          
          yaml.cleanup do |v|
            alert("rm_package", v['directory'])
            @package_count += 1
          end
          
          yaml.save
          
          # データベースのクリーンアップ
          Database.instance.cleanup do |record|
            alert("rm_record", record.path)
            @file_count += 1
          end
        end
      end
    end

    def rebuild(args, options)
      update_display_info(options)
      
      if (options[:all])
        db_delete(db_file)
        db_create(db_file)
        update_all
      else
        if (args.empty?)
          path = File.expand_path('.')
          package = yaml_load.package_root( path )

          if (package)
            print_result do
              db_open(db_file)
              remove_dir(package["directory"])
              add_dir(package["directory"])
            end
          else
            @out.puts "Not registered. '#{path}'."
          end
        else
          a_list = yaml_load.list CdstkYaml::Query.new(args)
          
          list(args, {:verbose => true})

          print_result do
            db_open(db_file)
            a_list.each do |content|
              remove_dir(content["directory"])
              add_dir(content["directory"])
            end
          end
        end
      end
    end

    def dump
      db_open(db_file)
      
      documents = Groonga::Context.default["documents"]
      records = documents.select
      records.each do |record|
        @out.puts record.inspect
        @out.puts "path : #{record.path}"
        @out.puts "shortpath : #{record.shortpath}"
        @out.puts "suffix : #{record.suffix}"
        @out.puts "timestamp : #{record.timestamp.strftime('%Y/%m/%d %H:%M:%S')}"
        @out.puts "content :", record.content ? record.content[0..64] : nil
        @out.puts
      end
      @out.puts "total #{records.size} record."
    end

    def dir(args, options)
      yaml = yaml_load
      
      if args.empty?
        path = File.expand_path('.')
        package = yaml.package_root(path)

        if (package)
          @out.print package['directory'] + (options[:top] ? "" : "\n")
        else
          # Use mcd.
          @out.print "Not registered." + (options[:top] ? "" : "\n")
        end
      else
        dirs = yaml.list(CdstkYaml::Query.new(args)).map{|v|v['directory']}.reverse

        if options[:top]
          unless (dirs.empty?)
            @out.print dirs[0]
          else
            @out.print ""
          end
        else
          @out.puts dirs
        end
      end
    end

    def setdb(args, options)
      if (options[:reset])
        CdstkCommand.setdb_reset
        @out.puts "Reset default db\n  remove:      #{Dbdir.milkode_db_dir}\n  default_db:  #{Dbdir.default_dir}"
      elsif (args.empty?)
        @out.puts Dbdir.default_dir
      else
        path = File.expand_path(args[0])
        begin
          CdstkCommand.setdb_set path
          @out.puts "Set default db #{path}."
        rescue CdstkCommand::NotExistDatabase
          @out.puts "fatal: '#{path}' is not database."
        end
      end
    end

    def mcd(args, options)
      @out.print <<EOF
# Copy to '.bashrc'.
mcd() {
    local args="$1 $2 $3 $4 $5 $6 $7 $8 $9"
    local dir=`milk dir --top $args`

    if [ "$dir" = "" ]; then
        echo "fatal: Not found package: $1 $2 $3 $4 $5 $6 $7 $8 $9"
    elif [ "$dir" = "Not registered." ]; then
        echo "fatal: Not a package dir: `pwd`"
    else
        cd $dir
        pwd
    fi
}

# For Cygwin.
mcd() {
    local args="$1 $2 $3 $4 $5 $6 $7 $8 $9"
    local dir=`milk.bat dir --top $args`

    if [ "$dir" = "" ]; then
        echo "fatal: Not found package: $1 $2 $3 $4 $5 $6 $7 $8 $9"
    elif [ "$dir" = "Not registered." ]; then
        echo "fatal: Not a package dir: `pwd`"
    else
        cd $dir
        pwd
    fi
}
EOF
    end

    def info(args, options)
      milkode_info
    end

    private

    def db_file
      Dbdir.expand_groonga_path(@db_dir)
    end

    def db_file_expand
      File.expand_path(db_file)
    end

    def db_dir_expand
      File.expand_path(@db_dir)
    end

    def custom_db?
      db_dir_expand != Dbdir.default_dir
    end

    def yaml_file
      CdstkYaml.yaml_file @db_dir
    end

    def yaml_load
      CdstkYaml.load(@db_dir)
    end

    def update_dir_in(dir)
      alert("package", File.basename(dir) )
      @package_count += 1
      
      dir = File.expand_path(dir)

      if (!FileTest.exist?(dir))
        @out.puts "[WARNING]  : #{dir} (Not found, skip)"
      elsif (FileTest.directory? dir)
        db_add_dir(dir)
      else
        db_add_file(STDOUT, dir, File.basename(dir))
      end
    end

    def remove_dir(dir)
      # yamlから削除
      yaml = yaml_load
      yaml.remove_dir(dir)
      yaml.save
        
      # データベースからも削除
      dir = File.expand_path(dir)

      alert("rm_package", dir)
      @package_count += 1

      Database.instance.remove([File.basename(dir)]) do |record|
        alert_info("rm_record", record.path)
        @file_count += 1
      end
    end

    def time
      @end_time - @start_time 
    end

    def print_result
      clear_count
      yield
      @end_time = Time.now
      
      result_info
      milkode_info
    end

    def result_info
      r = []
      r << "#{@package_count} packages" if @package_count > 0
      r << "#{@file_count} records" if @file_count > 0
      r << "#{@add_count} add" if @add_count > 0
      r << "#{@update_count} update" if @update_count > 0
      r.join(', ')
      alert('result', "#{r.join(', ')}. (#{Gren::Util::time_s(time)})")
    end

    def milkode_info
      alert('*milkode*', "#{yaml_load.package_num} packages, #{Database.instance.totalRecords} records in #{db_file}.")
    end

    def db_create(filename)
      dbfile = Pathname(File.expand_path(filename))
      dbdir = dbfile.dirname
      dbdir.mkpath unless dbdir.exist?
      
      unless dbfile.exist?
        Groonga::Database.create(:path => dbfile.to_s)
        db_define
        @out.puts "create     : #{filename} created."
      else
        @out.puts "message    : #{filename} already exist."
      end
    end

    def list_info(packages)
      option = FindGrep::FindGrep::DEFAULT_OPTION.dup
      option.dbFile = Dbdir.groonga_path(Dbdir.default_dir)
      option.isSilent = true
      option.packages = packages.map{|p| p.directory}
      findGrep = FindGrep::FindGrep.new([], option)
      records = findGrep.pickupRecords
      
      alert('*milk_list*', "#{packages.size} packages, #{records.size} records in #{db_file}.")
    end

    def db_define
      Groonga::Schema.define do |schema|
        schema.create_table("documents", :type => :hash) do |table|          
          table.string("path")
          table.string("shortpath")
          table.text("content")
          table.time("timestamp")
          table.text("suffix")
        end

        schema.create_table("terms",
                            :type => :patricia_trie,
                            :key_normalize => true,
                            :default_tokenizer => DEFAULT_TOKENIZER) do |table|
          table.index("documents.path", :with_position => true)
          table.index("documents.shortpath", :with_position => true)
          table.index("documents.content", :with_position => true)
          table.index("documents.suffix", :with_position => true)
        end
      end
    end

    def db_open(filename)
      dbfile = Pathname(File.expand_path(filename))
      
      if dbfile.exist?
        # データベースを開く
        Groonga::Database.open(dbfile.to_s)

        # 互換性テスト
        db_compatible?
      else
        raise "error      : #{dbfile.to_s} not found!!"
      end
    end

    def db_delete(filename)
      raise "Illegal file name : #{filename}." unless filename =~ /\.db$/
      Dir.glob("#{filename}*").each do |f|
        @out.puts "delete     : #{f}"
        FileUtils.rm_r(f)
      end
    end
    private :db_delete
      
    def db_add_dir(dirname)
      searchDirectory(STDOUT, dirname, File.basename(dirname), 0)
    end
    private :db_add_dir

    def db_add_file(stdout, filename, shortpath)
      # ファイル名を全てUTF-8に変換
      filename_utf8 = Util::filename_to_utf8(filename)
      shortpath_utf8 = Util::filename_to_utf8(shortpath)
      suffix_utf8 = File::extname(filename_utf8)
      
      # 格納するデータ
      values = {
        :path => filename_utf8,
        :shortpath => shortpath_utf8,
        :content => nil,
        :timestamp => File.mtime(filename),
        :suffix => suffix_utf8,
      }
      
      # 検索するデータベース
      documents = Groonga::Context.default["documents"]
      
      record = documents[ values[:path] ]
      isNewFile = false

      unless record
        document = documents.add(values[:path])
        isNewFile = true
      else
        document = record
      end
      
      # タイムスタンプが新しければデータベースに格納
      if (document[:timestamp] < values[:timestamp])
        # 実際に使うタイミングでファイルの内容を読み込み
        # values[:content] = open(filename).read
        # データベース内の文字コードは'utf-8'で統一
        values[:content] = Kconv.kconv(File.read(filename), Kconv::UTF8)
        
        # データベースに格納
        values.each do |key, value|
          if (key == :path)
            if (isNewFile)
              @add_count += 1
              alert_info("add_record", value)
            else
              @update_count += 1
              alert_info("update", value)
            end
          end
          document[key] = value
        end
      end

    end

    def searchDirectory(stdout, dir, shortdir, depth)
      Dir.foreach(dir) do |name|
        next if (name == '.' || name == '..')
          
        fpath = File.join(dir,name)
        shortpath = File.join(shortdir,name)
        
        # 除外ディレクトリならばパス
        next if ignoreDir?(fpath)

        # 読み込み不可ならばパス
        next unless FileTest.readable?(fpath)

        # ファイルならば中身を探索、ディレクトリならば再帰
        case File.ftype(fpath)
        when "directory"
          searchDirectory(stdout, fpath, shortpath, depth + 1)
        when "file"
          unless ignoreFile?(fpath)
            db_add_file(stdout, fpath, shortpath)
            @file_count += 1
            # @out.puts "file_count : #{@file_count}" if (@file_count % 100 == 0)
          end
        end          
      end
    end

    def ignoreDir?(fpath)
      FileTest.directory?(fpath) &&
      GrenFileTest::ignoreDir?(fpath)
    end
    private :ignoreDir?

    def ignoreFile?(fpath)
      GrenFileTest::ignoreFile?(fpath) ||
      GrenFileTest::binary?(fpath)
    end
    private :ignoreFile?

    def alert(title, msg)
      if (Util::platform_win?)
        @out.puts "#{title.ljust(10)} : #{Kconv.kconv(msg, Kconv::SJIS)}"
      else
        @out.puts "#{title.ljust(10)} : #{msg}"
      end
    end

    def alert_info(title, msg)
      alert(title, msg) if @is_display_info
    end

    def error_alert(msg)
      @out.puts "[fatal] #{msg}"
    end

    def db_compatible?
      begin
        db_define
      rescue Groonga::Schema::Error => e
        puts <<EOF
Milkode repository is old -> #{db_dir_expand}.
Please rebuild repository, 

  milk rebuild

See 'milk --help' or http://milkode.ongaeshi.me .
EOF
        exit -1
      end
    end

    def update_display_info(options)
      @is_display_info = true if (options[:verbose])
    end
  end
end
