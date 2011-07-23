# -*- coding: utf-8 -*-

require 'yaml'
require 'pathname'
require 'rubygems'
require 'groonga'
require 'fileutils'
require 'pathname'
require 'codestock/cdstk/cdstk_yaml'
require 'codestock/common/grenfiletest'
require 'codestock/common/util'
include CodeStock
require 'kconv'
require 'readline'
require 'codestock/cdweb/lib/database'

module CodeStock
  class Cdstk
    DB_FILE_PATH = 'db/grendb.db'
    
    # バイグラムでトークナイズする。連続する記号・アルファベット・数字は一語として扱う。
    # DEFAULT_TOKENIZER = "TokenBigram"

    # 記号・アルファベット・数字もバイグラムでトークナイズする。
    DEFAULT_TOKENIZER = "TokenBigramSplitSymbolAlphaDigit" 
    
    def initialize(io = $stdout, db_dir = ".")
      @db_dir = db_dir
      Database.setup(@db_dir)
      @out = io
      clear_count
    end

    def clear_count
      @package_count = 0
      @file_count = 0
      @add_count = 0
      @update_count = 0
      @start_time = Time.now
    end

    def init
      if Dir.entries(@db_dir) == [".", ".."]
        CdstkYaml.create(@db_dir)
        @out.puts "create     : #{yaml_file}"
        db_create(db_file)
      else
        @out.puts "Can't create milkode db (Because not empty in #{Dir.pwd})"
      end
    end

    def update(args = nil)
      print_result do 
        yaml = yaml_load
        query = args ? CdstkYaml::Query.new(args) : nil
        update_list = yaml_load.list(query)
        
        db_open(db_file)

        update_list.each do |content|
          update_dir_in(content["directory"])
        end
      end
    end

    def update_dir(dir)
      update_dir_in(dir)
    end

    def add(contents)
      # YAMLを読み込み
      yaml = yaml_load

      # コンテンツを読み込める形に変換
      contents.map!{|v|convert_content(v)}

      # 存在しないコンテンツがあった場合はその場で終了
      contents.each do |v|
        shortname = File.basename v
        if (yaml.exist? shortname)
          @out.puts "Already exist '#{shortname}'."
          return
        end
        
        unless (File.exist? v)
          @out.puts "Not found #{v}."
          return
        end
      end

      # YAML更新
      yaml.add(contents)
      yaml.save

      # 部分アップデート
      print_result do 
        db_open(db_file)
        contents.each do |dir|
          update_dir(dir)
        end
      end
    end

    def convert_content(src)
      # アーカイブファイルなら展開
      src = extract_file(src)

      # 絶対パスに変換
      File.expand_path(src)
    end

    def extract_file(src)
      ext = File.extname(src);
      
      case ext
      when '.zip', '.xpi'
        alert("extract", src)
        zip_dir = File.join(@db_dir, "packages/#{ext.sub(".", "")}")
        File.join(zip_dir, Util::zip_extract(src, zip_dir))

      else
        src
        
      end
    end

    def remove(args, is_force, is_verbose)
      print_result do 
        db_open(db_file)
        
        yaml = yaml_load
        query = CdstkYaml::Query.new(args)
        
        remove_list = yaml_load.list(query)
        return if remove_list.empty?
        
        list(args, true)
        
        if is_force or yes_or_no("Remove #{remove_list.size} contents? (yes/no)")
          # yamlから削除
          yaml.remove(query)
          yaml.save
          
          # データベースからも削除
          packages = remove_list.map{|v| File.basename v['directory']}

          # 本当はパッケージの配列をまとめて渡した方が効率が良いのだが、表示を綺麗にするため
          packages.each do |package|
            alert("rm_package", package)
            @package_count += 1
            
            Database.instance.remove(package) do |record|
              alert("rm_record", record.path)
              @file_count += 1
            end
          end
        end
      end
    end

    def yes_or_no(msg)
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

    def list(args, is_verbose)
      query = (args.empty?) ? nil : CdstkYaml::Query.new(args)
      a = yaml_load.list(query).map {|v| [File.basename(v['directory']), v['directory']] }
      max = a.map{|v|v[0].length}.max
      str = a.sort_by {|v|
        v[0]
      }.map {|v|
        h = File.exist?(v[1]) ? '' : '? '
        if (is_verbose)
          "#{(h + v[0]).ljust(max+2)} #{v[1]}"
        else
          "#{h}#{v[0]}"
        end
      }.join("\n")

      @out.puts  str
    end

    def pwd
      dir = db_file_expand
      
      if File.exist? dir
        @out.puts dir
      else
        @out.puts "Not found db in #{Dir.pwd}"
      end
    end

    def cleanup(options)
      if (options[:force] or yes_or_no("cleanup contents? (yes/no)"))
        # yamlファイルのクリーンアップ
        yaml = yaml_load
        yaml.cleanup
        yaml.save
        
        # データベースのクリーンアップ
        Database.instance.cleanup(options[:verbose] ? @out : nil)
      end
    end

    def rebuild
      db_delete(db_file)
      db_create(db_file)
      update
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

    private

    def db_file
      (Pathname.new(@db_dir) + DB_FILE_PATH).to_s
    end

    def db_file_expand
      File.expand_path(db_file)
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

    def time
      @end_time - @start_time 
    end

    def print_result
      clear_count
      
      yield
      
      @end_time = Time.now

      alert('result', "#{Gren::Util::time_s(time)}, #{@package_count} packages, #{@file_count} records, #{@add_count} add, #{@update_count} update.")
      alert('*milkode*', "#{yaml_load.package_num} package, #{Database.instance.totalRecords} records in #{db_file}.")
    end

    def db_create(filename)
      dbfile = Pathname(File.expand_path(filename))
      dbdir = dbfile.dirname
      dbdir.mkpath unless dbdir.exist?
      
      unless dbfile.exist?
        Groonga::Database.create(:path => dbfile.to_s)
        Groonga::Schema.define do |schema|
          schema.create_table("documents") do |table|
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
        @out.puts "create     : #{filename} created."
      else
        @out.puts "message    : #{filename} already exist."
      end
    end

    def db_open(filename)
      dbfile = Pathname(File.expand_path(filename))
      
      if dbfile.exist?
        Groonga::Database.open(dbfile.to_s)
        # @out.puts  "open       : #{dbfile} open."
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
      # 格納するデータ
      values = {
        :path => filename,
        :shortpath => shortpath,
        :content => nil,
        :timestamp => File.mtime(filename),
        :suffix => File::extname(filename),
      }
      
      # 検索するデータベース
      documents = Groonga::Context.default["documents"]
      
      # 既に登録されているファイルならばそれを上書き、そうでなければ新規レコードを作成
      _documents = documents.select do |record|
        record["path"] == values[:path]
      end
      
      isNewFile = false

      if _documents.size.zero?
        document = documents.add
        isNewFile = true
      else
        document = _documents.to_a[0].key
      end
      
      # タイムスタンプが新しければデータベースに格納
      if (document[:timestamp] < values[:timestamp])
        # 実際に使うタイミングでファイルの内容を読み込み
        # values[:content] = open(filename).read
        # データベース内の文字コードは'utf-8'で統一
        values[:content] = File.read(filename).kconv(Kconv::UTF8)
        
        # データベースに格納
        values.each do |key, value|
          if (key == :path)
            if (isNewFile)
              @add_count += 1
              alert("add_record", value)
            else
              @update_count += 1
              alert("update", value)
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
      @out.puts "#{title.ljust(10)} : #{msg}"
    end

  end
end
