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
      option.dbFile = Dbdir.groonga_path(Dbdir.default_dir)
      option.isSilent = true
      
      my_option = {}
      my_option[:packages] = []

      begin
        current_dir = package_root_dir(File.expand_path("."))
      rescue NotFoundPackage => e
        current_dir = File.expand_path(".")
      end
      
      find_mode = false
      
      # opt = OptionParser.new "#{File.basename($0)} [option] pattern"
      opt = OptionParser.new "gmilk [option] pattern" # @memo milk grep からも呼ばれるため
      opt.on('-f KEYWORD', '--file-keyword KEYWORD', 'File path. (Enable multiple call)') {|v| option.filePatterns << v; find_mode = true }
      opt.on('-d DIR', '--directory DIR', 'Start directory. (deafult:".")') {|v| current_dir = File.expand_path(v); find_mode = true} 
      opt.on('-s SUFFIX', '--suffix SUFFIX', 'Suffix.') {|v| option.suffixs << v } 
      opt.on('-r', '--root', 'Search from package root.') {|v| current_dir = package_root_dir(File.expand_path(".")) }
      opt.on('-p PACKAGE', '--package PACKAGE', 'Specify search package.') {|v| setup_package(option, my_option, v) }
      opt.on('-a', '--all', 'Search all package.') {|v| my_option[:all] = true }
      opt.on('-n NUM', 'Limits the number of match to show.') {|v| option.matchCountLimit = v.to_i }
      opt.on('-i', '--ignore', 'Ignore case.') {|v| option.ignoreCase = true}
      opt.on('--color', 'Color highlight.') {|v| option.colorHighlight = true}
      opt.on('--no-snip', 'There being a long line, it does not snip.') {|v| option.noSnip = true }
      opt.on('--cache', 'Search only db.') {|v| option.groongaOnly = true }
      opt.on('--verbose', 'Set the verbose level of output.') {|v| option.isSilent = false }
      opt.on('-u', '--update', 'With update db.') {|v| my_option[:update] = true }
      begin
        opt.parse!(arguments)
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

      if (arguments.size > 0 || find_mode)
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

        # findgrep
        findGrep = FindGrep::FindGrep.new(arguments, option)
        findGrep.searchAndPrint(stdout)
      else
        stdout.print opt.help
      end
    end

    private

    def self.setup_package(option, my_option, keyword)
      packages = yaml_load.list( CdstkYaml::Query.new(keyword) ).map{|v| v['directory']}
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

    # --- error ---
    class NotFoundPackage < RuntimeError ; end

  end
end
