# -*- coding: utf-8 -*-

require 'optparse'
require 'milkode/findgrep/findgrep'
require 'milkode/common/dbdir'
require 'milkode/cdstk/cdstk_yaml'
require 'milkode/cdstk/cdstk'

module Milkode
  class CLI_Grep
    def self.execute(stdout, arguments=[])
      option = FindGrep::FindGrep::DEFAULT_OPTION
      option.dbFile = Dbdir.groonga_path(Dbdir.default_dir)
      option.isSilent = true
      
      my_option = {}
      my_option[:packages] = []
      
      current_dir = File.expand_path('.')
      find_mode = false
      
      opt = OptionParser.new "#{File.basename($0)} [option] pattern"
      opt.on('-f KEYWORD', '--file-keyword KEYWORD', 'File path. (Enable multiple call)') {|v| option.filePatterns << v; find_mode = true }
      opt.on('-d DIR', '--directory DIR', 'Start directory. (deafult:".")') {|v| current_dir = File.expand_path(v); find_mode = true} 
      opt.on('-s SUFFIX', '--suffix SUFFIX', 'suffix.') {|v| option.suffixs << v } 
      opt.on('-r', '--root', 'XXX') {|v| current_dir = package_root_dir(File.expand_path(".")) }
      opt.on('-p PACKAGE', '--package PACKAGE', 'XXX') {|v| setup_package(option, my_option, v) }
      opt.on('-a', '--all', 'XXX') {|v| my_option[:all] = true }
      opt.on('-n NUM', 'Limits the number of match to show.') {|v| option.matchCountLimit = v.to_i }
      opt.on('-i', '--ignore', 'Ignore case.') {|v| option.ignoreCase = true}
      opt.on('-c', '--color', 'Color highlight.') {|v| option.colorHighlight = true}
      opt.on('--no-snip', 'There being a long line, it does not snip.') {|v| option.noSnip = true }
      opt.on('--groonga-only', 'Search only groonga db.') {|v| option.groongaOnly = true }
      opt.on('--verbose', 'XXX') {|v| option.isSilent = false }
      opt.on('-u', '--update', '') {|v| my_option[:update] = true }
      opt.parse!(arguments)
      
      if option.packages.empty? && !my_option[:all]
          option.filePatterns << current_dir
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
      option.packages += packages
      my_option[:packages] += packages
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
