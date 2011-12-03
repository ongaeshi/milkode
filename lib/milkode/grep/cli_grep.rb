# -*- coding: utf-8 -*-

require 'optparse'
require 'milkode/findgrep/findgrep'
require 'milkode/common/dbdir'

module Milkode
  class CLI_Grep
    def self.execute(stdout, arguments=[])
      option = FindGrep::FindGrep::DEFAULT_OPTION
      option.dbFile = Dbdir.groonga_path(Dbdir.default_dir)

      path = File.expand_path('.')
      option.filePatterns << path

      optvalue = Hash.new
      
      opt = OptionParser.new "#{File.basename($0)} [option] pattern"
      opt.on('-f KEYWORD', '--file-keyword KEYWORD', 'File path. (Enable multiple call)') {|v| option.filePatterns << v}
      opt.on('-p', '--package-root', 'Search package root.') {|v| optvalue[:package_root] = true }
      opt.parse!(arguments)

      # p option

      if (arguments.size > 0)
        findGrep = FindGrep::FindGrep.new(arguments, option)
        findGrep.searchAndPrint(stdout)
      else
        stdout.print opt.help
      end
    end
  end
end
