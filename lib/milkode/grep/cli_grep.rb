# -*- coding: utf-8 -*-

require 'kconv'
require 'milkode/cdstk/package'
require 'milkode/cdstk/yaml_file_wrapper'
require 'milkode/common/dbdir'
require 'milkode/common/util'
require 'milkode/grep/findgrep_option'
require 'optparse'
require 'tempfile'

module Milkode
  class CLI_Grep
    AUTO_EXTERNAL_RECORD_NUM = 500

    def self.execute(stdout, arguments=[])
      begin
        execute_in(stdout, arguments)
      rescue Interrupt
        puts
      end
    end

    def self.execute_in(stdout, arguments)
      # 引数の文字コードをUTF-8に変換
      if (Util.platform_win?)
        arguments = arguments.map{|arg| Kconv.kconv(arg, Kconv::UTF8)}
      end

      option = FindGrepOption::create_default

      # default option
      option.dbFile = Dbdir.groonga_path(Dbdir.default_dir)
      option.isSilent = true

      # local option
      my_option = {}
      my_option[:packages] = []

      # current dir's package
      current_package = nil
      current_dir     = nil

      begin
        current_package = package_root(File.expand_path("."))
      rescue NotFoundPackage => e
        current_dir = File.expand_path(".")
      end

      # opt = OptionParser.new "#{File.basename($0)} [option] pattern"
      opt = OptionParser.new <<EOF
gmilk [option] pattern
gmilk is 'milk grep'.

Stateful:
    -l,                              Change state 'line'. (Match line words.)
    -k,                              Change state 'keyword'. (Match file-content or file-path.)
    First state is 'line'.
    Example:
      gmilk line1 line2 -k keyword1 keyword2 -l line3 -k keyword3 ...

Gotoline:
    -g,                              Go to line mode.
    Enter a file name and line number. If you omit the line number jumps to the line:1.
    Example:
      gmilk -g database lib 7
      lib/database.rb:7:xxxxxxxxxxxxxxx
      database_lib.rb:7:yyyyyyyyyyyyyyy

      gmilk -g lib/database.rb:7 test/test_database.rb:5
      lib/database.rb:7:xxxxxxxxxxxxxxx
      test/test_database.rb:5:yyyyyyyyy

Normal:
EOF
      opt.on('-a', '--all', 'Search all package.') {|v| my_option[:all] = true }
      opt.on('-c', '--count', 'Display count num.') {|v| my_option[:count] = true }
      opt.on('--cache', 'Search only db.') {|v| option.groongaOnly = true }
      opt.on('--color', 'Color highlight.') {|v| option.colorHighlight = true}
      opt.on('--cs', '--case-sensitive', 'Case sensitivity.') {|v| option.caseSensitive = true }
      opt.on('-d DIR', '--directory DIR', 'Start directory. (deafult:".")') {|v| current_dir = File.expand_path(v); my_option[:find_mode] = true} 
      opt.on('--db DB_DIR', "Specify dbdir. (Use often with '-a')") {|v| option.dbFile = Dbdir.groonga_path(v) }
      opt.on('-e GREP', '--external-tool GREP', "Use external tool for file search. (e.g. grep, ag)") {|v| my_option[:external_tool] = v}
      opt.on('-f FILE_PATH', '--file-path FILE_PATH', 'File path. (Enable multiple call)') {|v| option.filePatterns << v; my_option[:find_mode] = true }
      opt.on('-i', '--ignore', 'Ignore case.') {|v| option.ignoreCase = true}
      opt.on('-m', '--match-files', 'Display match files.') {|v| my_option[:match_files] = true}
      opt.on('-n NUM', 'Limits the number of match to show.') {|v| option.matchCountLimit = v.to_i }
      opt.on('--no-external', 'Disable auto external.') {|v| my_option[:no_external] = true }
      opt.on('--no-snip', 'There being a long line, it does not snip.') {|v| option.noSnip = true }
      opt.on('-o ENCODE', '--output-encode ENCODE', 'Specify output encode(none, jis, sjis, euc, ascii, utf8, utf16). Default is "utf8"') {|v| option.output_kcode = Util.str2kcode(v) }
      opt.on('-p PACKAGE', '--package PACKAGE', 'Specify search package.') {|v| setup_package(option, my_option, v) }
      opt.on('-r', '--root', 'Search from package root.') {|v| current_dir = package_root_dir(File.expand_path(".")); my_option[:find_mode] = true }
      opt.on('-s SUFFIX', '--suffix SUFFIX', 'Suffix.') {|v| option.suffixs << v; my_option[:find_mode] = true } 
      opt.on('-u', '--update', 'With update db.') {|v| my_option[:update] = true }
      opt.on('--verbose', 'Set the verbose level of output.') {|v| option.isSilent = false }
      opt.on('-v', '--version', 'Show this version.') {|v| puts opt.ver ; exit }

      begin
        ap = ArgumentParser.new arguments
        
        ap.prev
        opt.parse!(arguments)
        ap.after

        arguments = ap.arguments

        option.keywords = ap.keywords
        my_option[:find_mode] = true unless ap.keywords.empty?

        unless ap.gotowords.empty?
          my_option[:find_mode] = true
          my_option[:gotoline_data] = Util.parse_gotoline(ap.gotowords)
        end

        # p ap.arguments
        # p ap.keywords
        # p ap.gotowords

      rescue NotFoundPackage => e
        stdout.puts "fatal: Not found package '#{e}'."
        return
      end

      # 最初の要素の先頭が'/'なら絶対パスモード
      is_abs_path = my_option[:gotoline_data] && my_option[:gotoline_data].first && (my_option[:gotoline_data][0][0][0][0..0] == '/')

      # 現在位置のパッケージを記録
      if option.packages.empty? && !my_option[:all] && !is_abs_path
        if current_dir && package_dir_in?(current_dir)
          option.filePatterns << current_dir
        elsif current_package
          option.strict_packages << current_package.name
        else
          stdout.puts "fatal: Not package dir '#{current_dir}'."
          return 
        end
      end

      if (arguments.size > 0 || my_option[:find_mode])
        # update
        if my_option[:update]
          require 'milkode/cdstk/cdstk'
          cdstk = Cdstk.new(stdout, Dbdir.select_dbdir)

          if (my_option[:all])
            cdstk.update_all({})
          elsif (my_option[:packages].empty?)
            cdstk.update_for_grep(package_root_dir(File.expand_path(".")))
          else
            my_option[:packages].each do |v|
              cdstk.update_for_grep(v)
            end
          end
          
          stdout.puts
        end

        if is_abs_path
          require 'milkode/grep/fast_gotoline'

          obj = FastGotoline.new(my_option[:gotoline_data], yaml_load)
          obj.search_and_print(stdout)
          
        else
          require 'milkode/grep/findgrep'

          if (my_option[:count])
            option.isSilent = true
            stdout.puts "#{pickup_records(arguments, option).size} records"
            
          elsif (my_option[:external_tool])
            option.isSilent = true
            records = pickup_records(arguments, option)

            case my_option[:external_tool]
            when 'grep'
              search_external_tool(arguments, option, records, 'grep -n', 'grep')              
            when 'ag'
              search_external_tool(arguments, option, records, 'ag', 'ag')
            else
              search_external_tool(arguments, option, records, my_option[:external_tool], my_option[:external_tool])
            end
            
          elsif (my_option[:match_files])
            option.isSilent = true
            records = pickup_records(arguments, option)
            files   = pickup_files(records, '\ ', option.matchCountLimit)

            files.each do |filename|
              stdout.puts filename
            end

          elsif my_option[:gotoline_data]
            # gotoline mode
            basePatterns = option.filePatterns 

            my_option[:gotoline_data].each do |v|
              if is_abs_path
                # @memo ここにはこないはず
                package, restpath = Util.divide_shortpath(v[0][0])
                # p [package, restpath]
                option.packages = [package]
                option.filePatterns = [restpath]
              else
                option.filePatterns = basePatterns + v[0]
              end
              
              option.gotoline = v[1]
              findGrep = FindGrep.new(arguments, option)
              findGrep.searchAndPrint(stdout)
            end
          else
            # normal search
            findGrep = FindGrep.new(arguments, option)
            records  = findGrep.pickupRecords
            
            if (my_option[:no_external] || records.length < AUTO_EXTERNAL_RECORD_NUM)
              findGrep.searchAndPrint2(stdout, records)
            else
              # レコード数が多い時は"-e grep"で検索
              if Util.exist_command?('cat') && Util.exist_command?('grep') && Util.exist_command?('xargs')
                $stderr.puts "Because number of records is large, Milkode use external tool. (Same as 'gmilk -e grep')"
                search_external_tool(arguments, option, records, 'grep -n', 'grep')
              else
                findGrep.searchAndPrint2(stdout, records)
              end
            end
              
          end
        end
      else
        stdout.print opt.help
      end
    end

    private

    def self.search_external_tool(arguments, option, records, first_command, second_command)
      files   = pickup_files(records, '\\\\ ', option.matchCountLimit)

      unless files.empty?
        cmd = []

        tmpfile = Tempfile.open("gmilk_external_tool")
        tmpfile.binmode
        tmpfile.write(files.join("\n"))
        tmpfile.close
        tmpfile.open
        cmd << "cat #{tmpfile.path}"

        cmd << "xargs #{first_command} #{arguments[0]}"

        (1...arguments.size).each do |index|
          cmd << "#{second_command} #{arguments[index]}"
        end

        system(cmd.join(" | "))

        tmpfile.close(true)
      end
    end

    def self.pickup_records(arguments, option)
      FindGrep.new(arguments, option).pickupRecords
    end

    def self.pickup_files(records, conv_space, length = -1)
      files = []
      records.each do |r|
        files << r.path.gsub(' ', conv_space) if File.exist?(r.path)
      end
      (length > 0) ? files[0, length] : files
    end

    def self.setup_package(option, my_option, keyword)
      # @memo package指定が簡単になった
      # dirs = yaml_load.contents.find_all {|p| p.name.include? keyword }.map{|p| p.directory}
      dirs = yaml_load.contents.find_all {|p| p.name.include? keyword }.map{|p| p.name}
      raise NotFoundPackage.new keyword if (dirs.empty?)
      option.packages += dirs
      my_option[:packages] += dirs
    end

    def self.package_dir_in?(dir)
      yaml_load.package_root(dir)
    end

    def self.package_root_dir(dir)
      package_root = yaml_load.package_root(dir)

      if (package_root)
        package_root.directory
      else
        raise NotFoundPackage.new dir
      end
    end

    def self.package_root(dir)
      package_root = yaml_load.package_root(dir)

      if (package_root)
        package_root
      else
        raise NotFoundPackage.new dir
      end
    end

    def self.yaml_load
      YamlFileWrapper.load(Dbdir.select_dbdir)
    end

    class ArgumentParser
      attr_reader :arguments
      attr_reader :keywords
      attr_reader :gotowords
      
      def initialize(arguments)
        @arguments = arguments
        @state = :line
        @keywords = []
        @gotowords = []
      end

      def prev
        @arguments.map! do |v|
          case v
          when "-l"
            ":l"
          when "-k"
            ":k"
          when "-g"
            ":g"
          else
            v
          end
        end
      end

      def after
        if @arguments.first
          if Util.gotoline_keyword? @arguments[0]
            @state = :gotoline
          end
        end

        result = []

        @arguments.each do |v|
          case v
          when ":l"
            @state = :line
            next
          when ":k"
            @state = :keyword
            next
          when ":g"
            @state = :gotoline
            @gotowords += result
            result = []
            next
          end

          case @state
          when :line
            result << v
          when :keyword
            @keywords << v
          when :gotoline
            @gotowords << v
          end
        end

        @arguments = result
      end
    end

    # --- error ---
    class NotFoundPackage < RuntimeError ; end

  end
end
