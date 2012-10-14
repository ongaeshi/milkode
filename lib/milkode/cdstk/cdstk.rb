# -*- coding: utf-8 -*-

require 'yaml'
require 'pathname'
require 'rubygems'
require 'fileutils'
require 'pathname'
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
require 'open-uri'
require 'milkode/cdstk/cdstk_command'
require 'milkode/cdstk/yaml_file_wrapper'
require 'milkode/cdstk/package'
require 'milkode/common/ignore_checker'
require 'milkode/database/groonga_database'
require 'milkode/database/document_record'
require 'milkode/common/array_diff'
require 'milkode/database/updater'
require 'milkode/common/plang_detector'

module Milkode
  class IgnoreError < RuntimeError ; end

  class Cdstk
    # バイグラムでトークナイズする。連続する記号・アルファベット・数字は一語として扱う。
    # DEFAULT_TOKENIZER = "TokenBigram"

    # 記号・アルファベット・数字もバイグラムでトークナイズする。
    DEFAULT_TOKENIZER = "TokenBigramSplitSymbolAlphaDigit"

    class ConvetError < RuntimeError ; end
    
    def initialize(io = $stdout, db_dir = ".")
      @db_dir = db_dir
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
        db_create
        setdb([@db_dir], {}) if (options[:setdb])
      else
        @out.puts "Can't create milkode db (Because not empty in #{db_dir_expand})"
      end
    end

    def assert_compatible
      db_open
    end

    def update_all(options)
      print_result do 
        db_open

        @yaml.contents.each do |package|
          update_package_in(package, options)
        end
      end
    end

    def update(args, options)
      update_display_info(options)

      if (options[:all])
        update_all(options)
      else
        if (args.empty?)
          path = File.expand_path('.')
          package = @yaml.package_root(path)

          if (package)
            print_result do
              db_open
              update_package_in(package, options)
            end
          else
            @out.puts "Not registered. If you want to add, 'milk add #{path}'."
          end
        else
          print_result do
            db_open
            args.each do |name|
              package = @yaml.find_name(name)
              if (package)
                update_package_in(package, options)
              else
                @out.puts "Not found package '#{name}'."
                return
              end
            end
          end
        end
      end
    end

    def update_for_grep(dir)
      db_open
      update_dir_in(dir)
    end

    def add(dirs, options)
      update_display_info(options)

      print_result do
        # データベースを開く
        db_open

        # メイン処理
        begin
          dirs.each do |v|
            # コンテンツを読み込める形に変換
            dir = convert_content(v)

            # YAMLに追加
            package = Package.create(dir, options[:ignore])
            add_yaml(package)

            # オプション設定
            is_update_with_git_pull = git_url?(v)
            set_yaml_options(package, options, is_update_with_git_pull)

            # アップデート
            update_dir_in(dir)
          end
        rescue ConvetError
          return
        end
      end
    end

    def set_yaml_options(package, options, is_update_with_git_pull)
      is_dirty = false
      
      if options[:no_auto_ignore]
        dst = package.options
        dst[:no_auto_ignore] = true
        package.set_options(dst)
        is_dirty = true
      end

      if options[:name]
        dst = package.options
        dst[:name] = src[:name]
        package.set_options(dst)
        is_dirty = true
      end

      if is_update_with_git_pull
        dst = package.options
        dst[:update_with_git_pull] = is_update_with_git_pull
        package.set_options(dst)
        is_dirty = true
      end

      if is_dirty
        @yaml.update(package)
        @yaml.save
      end
    end

    def add_dir(dir, no_yaml = false)
      add_yaml(Package.create(dir)) unless no_yaml
      db_open
      update_dir_in(dir)
    end

    # yamlにパッケージを追加
    def add_yaml(package)
      # すでに同名パッケージがある
      if @yaml.find_name(package.name)
        warning_alert("already exist '#{package.name}'.")
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

      # データベースを開く
      db_open

      # yamlファイルと同期する
      @grndb.yaml_sync(@yaml.contents)
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
      elsif (git_url? src)
        git_clone_in(src)
      else
        src
      end
    end

    def git_url?(src)
      Util::git_url?(src)
    end
    private :git_url?

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

    def git_clone_in(url)
      alert("git", url)

      dst_dir = File.join(@db_dir, "packages/git")
      # FileUtils.mkdir_p dst_dir

      filename = File.join(dst_dir, File.basename(url).sub(/\.git\Z/, ""))

      # git output progress to stderr.
      # `git clone #{url} #{filename} 2>&1`

      # with output
      system("git clone #{url} #{filename}")

      filename
    end

    def remove_all
      print_result do
        list([], {:verbose => true})
        
        if yes_or_no("Remove #{@yaml.contents.size} contents? (yes/no)")
          db_open

          @yaml.contents.each do |package|
            remove_dir(package.directory)
          end
        else
          return
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
              db_open
              remove_dir(package.directory)
            end
          else
            @out.puts "Not registered. '#{path}'."
          end
        else
          print_result do
            db_open
            args.each do |name|
              package = @yaml.find_name(name) || @yaml.find_dir(name)
              if (package)
                remove_dir(package.directory)                
              else
                @out.puts "Not found package '#{name}'."
                return
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
      if options[:check]
        check_integrity
        return
      end
      
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

      if Util.pipe? $stdout
        if args.empty?
          milkode_info
        else
          list_info(match_p) unless match_p.empty?
        end
      end
    end

    def fav(args, options)
      db_open

      if (args.empty?)
        @out.puts @grndb.packages.favs.map{|r| r.name}
      else
        is_dirty = false

        args.each do |v|
          # database
          time = options[:delete] ? Time.at(0) : Time.now

          if @grndb.packages.touch_if(v, :favtime, time)
            # milkode_yaml
            package = @yaml.find_name(v)
            dst = package.options
            unless options[:delete]
              dst[:fav] = true
            else
              dst.delete(:fav)
            end
            package.set_options(dst)
            @yaml.update(package)
            is_dirty = true
          else
            @out.puts "Not found package '#{v}'"
          end
        end

        @yaml.save if is_dirty
      end
    end

    def check_integrity
      db_open

      @out.puts "Check integrity ..."

      yaml = @yaml.contents.map {|p| p.name}.sort
      grndb = @grndb.packages.map {|p| p.name}.sort

      d = yaml.diff grndb

      unless d[0].empty?
        @out.puts "'milkode.yaml' has #{d[0]}, but 'PackageTable' don't have."
      end

      unless d[1].empty?
        @out.puts "'PackageTable' has #{d[1]}, but 'milkode.yaml' don't have."
      end

      if d[0].empty? && d[1].empty?
        @out.puts 'ok'
      end
    end

    def pwd(options)
      dir = options[:default] ? Dbdir.default_dir : db_dir_expand
      
      if File.exist? dir
        if options[:default]
          @out.puts dir
        else
          package = @yaml.package_root(File.expand_path('.'))
          name = package ? package.name : "'not_package_dir'"
          @out.puts "#{name} in #{dir}"
        end
      else
        @out.puts "Not found db in #{Dir.pwd}"
      end
    end

    def cleanup(options)
      # cleanup開始
      if (options[:force] or yes_or_no("cleanup contents? (yes/no)"))
        print_result do 
          # yamlファイルのクリーンアップ
          @yaml.contents.find_all {|v| !File.exist? v.directory }.each do |p|
            @yaml.remove(p)
            alert("rm_package", p.directory)
            @package_count += 1
          end
          @yaml.save

          # データベースを開く
          db_open

          # yamlファイルと同期する
          @grndb.yaml_sync(@yaml.contents)
          
          # データベースのクリーンアップ
          @documents.cleanup do |record|
            alert("rm_record", record.path)
            @file_count += 1
          end
        end
      end
    end

    def rebuild(args, options)
      update_display_info(options)
      
      if (options[:all])
        db_delete
        db_create
        @grndb.yaml_sync(@yaml.contents)
        update_all({})
      else
        if (args.empty?)
          path = File.expand_path('.')
          package = @yaml.package_root(path)

          if (package)
            print_result do
              db_open
              remove_dir(package.directory, true)
              add_dir(package.directory, true)
            end
          else
            @out.puts "Not registered. '#{path}'."
          end
        else
          print_result do
            args.each do |name|
              package = @yaml.find_name(name)
              if (package)
                db_open
                remove_dir(package.directory, true)
                add_dir(package.directory, true)
              else
                @out.puts "Not found package '#{name}'."
                return
              end
            end
          end
        end
      end
    end

    def dump
      db_open

      @documents.each do |grnrcd|
        record = DocumentRecord.new grnrcd
        
        @out.puts record.inspect
        @out.puts "path : #{record.path}"
        @out.puts "shortpath : #{record.shortpath}"
        @out.puts "suffix : #{record.suffix}"
        @out.puts "timestamp : #{record.timestamp.strftime('%Y/%m/%d %H:%M:%S')}"
        @out.puts "content :", record.content ? record.content[0..64] : nil
        @out.puts
      end

      @out.puts "total #{@documents.size} record."
    end

    def dir(args, options)
      if args.empty?
        path = File.expand_path('.')
        package = @yaml.package_root(path)

        if (package)
          @out.print package.directory + (options[:top] ? "" : "\n")
        else
          # Use mcd.
          @out.print "Not registered." + (options[:top] ? "" : "\n")
        end
      else
        match_p = @yaml.contents.find_all do |p|
          args.all? {|k| p.name.include? k }
        end

        dirs = match_p.map{|v|v.directory}.reverse

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

    def setdb(dbpath, options)
      if (options[:reset])
        CdstkCommand.setdb_reset
        @out.puts "Reset default db\n  remove:      #{Dbdir.milkode_db_dir}\n  default_db:  #{Dbdir.default_dir}"
      elsif (dbpath.nil?)
        @out.puts Dbdir.default_dir
      else
        path = File.expand_path(dbpath)
        begin
          CdstkCommand.setdb_set path
          @out.puts "Set default db #{path}."
        rescue CdstkCommand::NotExistDatabase
          @out.puts "fatal: '#{path}' is not database."
        end
      end
    end

    def mcd(options)
      if options[:shell] != 'cygwin'
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
EOF
      end

      if options[:shell] != 'sh'
        @out.print <<EOF
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
    end

    def info(args, options)
      db_open

      if options[:all]
        info_format(@yaml.contents, select_format(options, :table))
        milkode_info
        return
      end

      packages = find_packages(args)
      packages.compact!
      return if (packages.empty?)

      info_format(packages, select_format(options, :detail))
    end

    def select_format(options, default_value)
      format = default_value
      format = :detail     if options[:detail]
      format = :table      if options[:table]
      format = :breakdown  if options[:breakdown]
      format = :unknown    if options[:unknown]
      format
    end

    def info_format(packages, format)
      case format
      when :detail
        info_format_detail(packages)
      when :table
        info_format_table(packages)        
      when :breakdown
        info_format_breakdown(packages)        
      when :unknown
        info_format_unknown(packages)
      end
    end

    def info_format_detail(packages)
      packages.each_with_index do |package, index|
        records = package_records(package.name)

        r = []
        r.push "Name:      #{package.name}"
        r.push "Ignore:    #{package.ignore}" unless package.ignore.empty?
        r.push "Options:   #{package.options}" unless package.options.empty?
        r.push "Records:   #{records.size}"
        r.push "Breakdown: #{breakdown_shorten(records)}"
        r.push "Linecount: #{linecount_total(records)}"
        r.push ""

        @out.puts if index != 0
        @out.puts r.join("\n")
      end
    end

    NAME  = 'Name'
    TOTAL = 'Total'
    
    def info_format_table(packages)
      max = packages.map{|p| p.name.length}.max
      max = NAME.length  if max < NAME.length

      @out.puts <<EOF.chomp
#{NAME.ljust(max)}     Records   Linecount
#{'=' * max}========================
EOF

      packages.each do |package|
        records = package_records(package.name)
        @out.puts "#{package.name.ljust(max)}  #{records.size.to_s.rjust(10)}  #{linecount_total(records).to_s.rjust(10)}"
      end
    end

    def info_format_breakdown(packages)
      packages.each_with_index do |package, index|
        records = package_records(package.name)
        plangs = sorted_plangs(records)

        # column1's width
        plang_names = plangs.map{|v| v[0]}
        max = (plang_names + [package.name, TOTAL]).map{|name| name.length}.max
        
        @out.puts if index != 0
      @out.puts <<EOF.chomp
#{package.name.ljust(max)}  files  rate
#{'=' * max}=============
#{breakdown_detail(package_records(package.name), max)}
#{'-' * max}-------------
#{sprintf("%-#{max}s  %5d  %3d%%", TOTAL, records.size, 100)}
EOF
      end
    end

    def info_format_unknown(packages)
      packages.each_with_index do |package, index|
        @out.puts if index != 0

        package_records(package.name).each do |record|
          path = record.restpath
          @out.puts path if PlangDetector.new(path).unknown?
        end
      end
    end

    def package_records(name)
      @documents.search(:strict_packages => [name])
    end

    def linecount_total(records)
      records.reduce(0) do |total, record|
        begin
          unless record.content.nil?
            total + record.content.count($/) + 1
          else
            total
          end
        rescue ArgumentError
          warning_alert("invalid byte sequence : #{record.path}")
          total
        end
      end
    end

    def sorted_plangs(records)
      total = {}
      
      records.each do |record|
        lang = PlangDetector.new(record.restpath)

        if total[lang.name]
          total[lang.name] += 1
        else
          total[lang.name] = 1
        end
      end

      total.map {|name, count|
        [name, count]
      }.sort {|a, b|
        if (a[0] == PlangDetector::UNKNOWN)
          -1
        elsif (b[0] == PlangDetector::UNKNOWN)
          1
        else
          a[1] <=> b[1]
        end
      }.reverse
    end

    def calc_percent(count, size)
      (count.to_f / size * 100).to_i
    end

    def breakdown_shorten(records)
      plangs = sorted_plangs(records)

      plangs = plangs.reduce([]) {|array, plang|
        name, count = plang
        percent = calc_percent(count, records.size)

        if percent == 0
          if array.empty? || array[-1][0] != 'other'
            array << ['other', count]
          else
            array[-1][1] += count
          end
        else
          array << plang
        end

        array
      }
      
      plangs.map {|name, count|
        percent = calc_percent(count, records.size)
        "#{name}:#{count}(#{percent}%)"
      }.join(', ')
    end

    def breakdown_detail(records, name_width)
      sorted_plangs(records).map {|name, count|
        percent = (count.to_f / records.size * 100).to_i
        sprintf("%-#{name_width}s  %5d  %3d%%", name, count, percent)
      }.join("\n")
    end

    # 引数が指定されている時は名前にマッチするパッケージを、未指定の時は現在位置から見つける
    def find_packages(args)
      unless args.empty?
        args.map do |v|
          r = @yaml.find_name(v)
          @out.puts "Not found package '#{v}'." if r.nil?
          r
        end
      else
        dir = File.expand_path('.')
        r = @yaml.package_root(dir)
        @out.puts "Not registered '#{dir}'." if r.nil?
        [r]
      end
    end

    def ignore(args, options)
      current_dir = File.expand_path('.')

      if (options[:package])
        package = @yaml.find_name(options[:package])
        raise IgnoreError, "Not found package '#{options[:package]}'." unless package
      else
        package = @yaml.package_root(current_dir)
        raise IgnoreError, "Not a package dir: '#{current_dir}'" unless package
      end

      if options[:dry_run]
        # Test mode
        db_open
        @is_display_info = true
        @is_silent = true
        update_dir_in(package.directory)
      elsif options[:delete_all]
        # Delete all
        package.set_ignore([])
        @yaml.update(package)
        @yaml.save
      elsif args.empty?
        # Display ignore settting
        @out.puts package.ignore
      else
        # Add or Delete
        if options[:package]
          add_ignore = args.map {|v| v.sub(/^.\//, "") }
        else
          path = Util::relative_path(File.expand_path('.'), package.directory).to_s
          add_ignore = args.map {|v| File.join(path, v).sub(/^.\//, "") }
        end

        ignore = package.ignore

        if options[:delete]
          ignore -= add_ignore          
        else
          ignore += add_ignore
        end
        ignore.uniq!
        package.set_ignore(ignore)
        
        @yaml.update(package)
        @yaml.save

        if options[:delete]
          @out.puts add_ignore.map{|v| "Delete : #{v}"}
        else
          @out.puts add_ignore.map{|v| "Add : #{v}"}
        end
      end
    end

    def files(args)
      packages = find_packages(args)
      return if (packages.empty?)

      db_open
      
      packages.each do |package|
        package_records(package.name).each do |record|
          @out.puts record.restpath
        end
      end
    end

    private

    def db_file
      Dbdir.expand_groonga_path(@db_dir)
    end

    def db_dir_expand
      File.expand_path(@db_dir)
    end

    def yaml_file
      YamlFileWrapper.yaml_file @db_dir
    end

    def update_package_in(package, options)
      updater_exec(package, package.options[:update_with_git_pull], options[:no_clean])
    end

    def update_dir_in(dir)
      dir = File.expand_path(dir)

      if (!FileTest.exist?(dir))
        warning_alert("#{dir} (Not found, skip)")
      else
        package = @yaml.package_root(dir)
        updater_exec(package, false, false)
      end
    end

    def updater_exec(package, is_update_with_git_pull, is_no_clean)
      alert("package", package.name )

      updater = Updater.new(@grndb, package.name)
      updater.set_package_ignore IgnoreSetting.new("/", package.ignore)
      updater.enable_no_auto_ignore       if package.options[:no_auto_ignore]
      updater.enable_silent_mode          if @is_silent
      updater.enable_display_info         if @is_display_info
      updater.enable_update_with_git_pull if is_update_with_git_pull
      updater.enable_no_clean             if is_no_clean
      updater.exec

      @package_count += 1
      @file_count   += updater.result.file_count
      @add_count    += updater.result.add_count
      @update_count += updater.result.update_count
    end

    def remove_dir(dir, no_yaml = false)
      unless (no_yaml)
        package = @yaml.find_dir(dir)

        # yamlから削除
        @yaml.remove(package)
        @yaml.save

        # PackageTableから削除
        db_open
        @grndb.packages.remove package.name
      end

      # データベース開く
      db_open

      # データベースからも削除
      # dir = File.expand_path(dir)

      alert("rm_package", dir)
      @package_count += 1

      @documents.remove_match_path(dir) do |record|
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
      alert('result', "#{r.join(', ')}. (#{Gren::Util::time_s(time)})")
    end

    def milkode_info
      db_open
      alert('*milkode*', "#{@yaml.contents.size} packages, #{@documents.size} records in #{db_file}.")
    end

    def db_create
      filename = db_file
      
      unless File.exist? filename
        db_open
        @out.puts "create     : #{filename} created."
      else
        @out.puts "message    : #{filename} already exist."
      end
    end

    def list_info(packages)
      db_open
      records = @documents.search(:packages => packages.map{|p| p.name})
      alert('*milk_list*', "#{packages.size} packages, #{records.size} records in #{db_file}.")
    end

    def db_open
      if !@grndb || @grndb.closed?
        @grndb = GroongaDatabase.new
        @grndb.open(@db_dir)
        @documents = @grndb.documents
      end
    end

    def db_delete
      filename = db_file

      raise "Illegal file name : #{filename}." unless filename =~ /\.db$/

      Dir.glob("#{filename}*").each do |f|
        @out.puts "delete     : #{f}"
        FileUtils.rm_r(f)
      end
    end
      
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

    def warning_alert(msg)
      @out.puts "[warning] #{msg}"
    end

    def error_alert(msg)
      @out.puts "[error] #{msg}"
    end

    def update_display_info(options)
      @is_display_info = true if (options[:verbose])
    end
  end
end
