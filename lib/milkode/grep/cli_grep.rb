# -*- coding: utf-8 -*-

require 'optparse'
require 'milkode/findgrep/findgrep'
require 'milkode/common/dbdir'
require 'milkode/cdstk/cdstk_yaml'

module Milkode
  class CLI_Grep
    def self.execute(stdout, arguments=[])
      option = FindGrep::FindGrep::DEFAULT_OPTION
      option.dbFile = Dbdir.groonga_path(Dbdir.default_dir)
      option.isSilent = true

      current_dir = File.expand_path('.')
      all_package = false
      find_mode = false
      
      opt = OptionParser.new "#{File.basename($0)} [option] pattern"
      opt.on('-f KEYWORD', '--file-keyword KEYWORD', 'File path. (Enable multiple call)') {|v| option.filePatterns << v; find_mode = true }
      opt.on('-d DIR', '--directory DIR', 'Start directory. (deafult:".")') {|v| current_dir = File.expand_path(v); find_mode = true} 
      opt.on('-s SUFFIX', '--suffix SUFFIX', 'suffix.') {|v| option.suffixs << v } 
      opt.on('-r', '--root', 'XXX') {|v| current_dir = package_root_dir(File.expand_path(".")) }
      opt.on('-p PACKAGE', '--package PACKAGE', 'XXX') {|v| setup_package(option, v) }
      opt.on('-a', '--all', 'XXX') {|v| all_package = true }
      opt.on('-n NUM', 'Limits the number of match to show.') {|v| option.matchCountLimit = v.to_i }
      opt.parse!(arguments)
      
      if option.packages.empty? && !all_package
          option.filePatterns << current_dir
      end

      # p option

      if (arguments.size > 0 || find_mode)
        findGrep = FindGrep::FindGrep.new(arguments, option)
        findGrep.searchAndPrint(stdout)
      else
        stdout.print opt.help
      end
    end

    private

    def self.setup_package(option, keyword)
      packages = yaml_load.list( CdstkYaml::Query.new(keyword) ).map{|v| v['directory']}
      option.packages += packages
    end

    def self.package_root_dir(dir)
      package_root = yaml_load.package_root_dir(dir)

      if (package_root)
        package_root
      else
        raise "XXX(Not found root)."
      end
    end

    def self.yaml_load
      CdstkYaml.load(Dbdir.select_dbdir)
    end
  end
end
