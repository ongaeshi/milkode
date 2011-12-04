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

      current_dir = File.expand_path('.')
      
      opt = OptionParser.new "#{File.basename($0)} [option] pattern"
      opt.on('-f KEYWORD', '--file-keyword KEYWORD', 'File path. (Enable multiple call)') {|v| option.filePatterns << v}
      opt.on('-d DIR', '--directory DIR', 'Start directory. (deafult:".")') {|v| current_dir = File.expand_path(v) } 
      opt.on('-s SUFFIX', '--suffix SUFFIX', 'suffix.') {|v| option.suffixs << v } 
      opt.on('-r', '--root', 'XXX') {|v| current_dir = package_root_dir(File.expand_path(".")) }
      opt.on('-p PACKAGE', '--package PACKAGE', 'XXX') {|v| }
      opt.parse!(arguments)
     
      option.filePatterns << current_dir

      # p option

      if (arguments.size > 0)
        findGrep = FindGrep::FindGrep.new(arguments, option)
        findGrep.searchAndPrint(stdout)
      else
        stdout.print opt.help
      end
    end

    private 

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
