# -*- coding: utf-8 -*-

require 'optparse'
require 'milkode/findgrep/findgrep'
require 'milkode/common/dbdir'
require 'milkode/cdstk/cdstk_yaml'
require 'milkode/cdstk/cdstk'

module Milkode
  class CLI_Grep
    def self.execute(stdout, arguments=[])
      option = FindGrep::FindGrep::DEFAULT_OPTION.dup

      # default option
      option.dbFile = Dbdir.groonga_path(Dbdir.default_dir)
      option.isSilent = true

      # local option
      my_option = {}
      my_option[:packages] = []

      begin
        current_dir = package_root_dir(File.expand_path("."))
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

Normal:
EOF
      opt.on('-a', '--all', 'Search all package.') {|v| my_option[:all] = true }
      opt.on('-c', '--count', 'Disp count num.') {|v| my_option[:count] = true }
      opt.on('--cache', 'Search only db.') {|v| option.groongaOnly = true }
      opt.on('--color', 'Color highlight.') {|v| option.colorHighlight = true}
      opt.on('--cs', '--case-sensitive', 'Case sensitivity.') {|v| my_option[:case_sensitive] = true }
      opt.on('-d DIR', '--directory DIR', 'Start directory. (deafult:".")') {|v| current_dir = File.expand_path(v); my_option[:find_mode] = true} 
      opt.on('-f FILE_PATH', '--file-path FILE_PATH', 'File path. (Enable multiple call)') {|v| option.filePatterns << v; my_option[:find_mode] = true }
      opt.on('-n NUM', 'Limits the number of match to show.') {|v| option.matchCountLimit = v.to_i }
      opt.on('--no-snip', 'There being a long line, it does not snip.') {|v| option.noSnip = true }
      opt.on('-p PACKAGE', '--package PACKAGE', 'Specify search package.') {|v| setup_package(option, my_option, v) }
      opt.on('-r', '--root', 'Search from package root.') {|v| current_dir = package_root_dir(File.expand_path(".")); my_option[:find_mode] = true }
      opt.on('-s SUFFIX', '--suffix SUFFIX', 'Suffix.') {|v| option.suffixs << v; my_option[:find_mode] = true } 
      opt.on('-u', '--update', 'With update db.') {|v| my_option[:update] = true }
      opt.on('--verbose', 'Set the verbose level of output.') {|v| option.isSilent = false }

      begin
        ap = ArgumentParser.new arguments
        
        ap.prev
        opt.parse!(arguments)
        ap.after

        arguments = ap.arguments
        option.keywords = ap.keywords
        my_option[:find_mode] = true unless ap.keywords.empty?

        # p ap.arguments
        # p ap.keywords

      rescue NotFoundPackage => e
        stdout.puts "fatal: Not found package '#{e}'."
        return
      end

      if option.packages.empty? && !my_option[:all]
        if (package_dir_in? current_dir)
          option.filePatterns << current_dir
        else
          stdout.puts "fatal: Not package dir '#{current_dir}'."
          return 
        end
      end

      if (arguments.size > 0 || my_option[:find_mode])
        # ignore?
        downcase_all = arguments.all? {|v| Util::downcase? v}
        option.ignoreCase = true if downcase_all && !my_option[:case_sensitive]

        # update
        if my_option[:update]
          cdstk = Cdstk.new(stdout, Dbdir.select_dbdir)

          if (my_option[:all])
            cdstk.update_all
          elsif (my_option[:packages].empty?)
            cdstk.update_package(package_root_dir(File.expand_path(".")))
          else
            my_option[:packages].each do |v|
              cdstk.update_package(v)
            end
          end
          
          stdout.puts
        end

        if (my_option[:count])
          # count mode
          option.isSilent = true
          findGrep = FindGrep::FindGrep.new(arguments, option)
          records = findGrep.pickupRecords
          # stdout.puts "#{records.size} records (#{findGrep.time_s})"
          stdout.puts "#{records.size} records"
        else
          # search mode
          findGrep = FindGrep::FindGrep.new(arguments, option)
          findGrep.searchAndPrint(stdout)
        end
      else
        stdout.print opt.help
      end
    end

    private

    def self.setup_package(option, my_option, keyword)
      packages = yaml_load.list( CdstkYaml::Query.new([keyword]) ).map{|v| v['directory']}
      raise NotFoundPackage.new keyword if (packages.empty?)
      option.packages += packages
      my_option[:packages] += packages
    end

    def self.package_dir_in?(dir)
      yaml_load.package_root_dir(dir)
    end

    def self.package_root_dir(dir)
      package_root = yaml_load.package_root_dir(dir)

      if (package_root)
        package_root
      else
        raise NotFoundPackage.new dir
      end
    end

    def self.yaml_load
      CdstkYaml.load(Dbdir.select_dbdir)
    end

    class ArgumentParser
      attr_reader :arguments
      attr_reader :keywords
      
      def initialize(arguments)
        @arguments = arguments
        @keywords = []
        @state = :line
      end

      def prev
        @arguments.map! do |v|
          v.gsub("-l", ":l").
            gsub("-k", ":k")
        end
      end

      def after
        result = []
        
        @arguments.each do |v|
          case v
          when ":l"
            @state = :line
            next
          when ":k"
            @state = :keyword
            next
          end

          case @state
          when :line
            result << v
          when :keyword
            @keywords << v
          end
        end

        @arguments = result
      end
    end

    # --- error ---
    class NotFoundPackage < RuntimeError ; end

  end
end
