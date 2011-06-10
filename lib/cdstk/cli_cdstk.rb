# -*- coding: utf-8 -*-
require 'optparse'
require 'cdstk/cdstk'
require 'common/dbdir.rb'
include CodeStock

module CodeStock
  class CLI_Cdstk
    def self.execute(stdout, arguments=[])
      opt = OptionParser.new <<EOF
#{File.basename($0)} COMMAND [ARGS]

The most commonly used #{File.basename($0)} are:
  init        Init db.
  update      Update db.
  add         Add contents. (ex. ~/Documents/cdstock, git://github.com/ongaeshi/cdstock.git)
  remove      Remove contents.
  list        List all contents. 
  rebuild     Rebuild db.
  dump        Dump database contents.
EOF

      subopt = Hash.new
      
      init_default = false
      subopt['init'] = OptionParser.new("#{File.basename($0)} init")
      subopt['init'].on('--default', 'Init db default path. (Maybe ~/.codestock)') { init_default = true }
      
      subopt['update'] = OptionParser.new("#{File.basename($0)} update")
      subopt['add'] = OptionParser.new("#{File.basename($0)} add content1 [content2 ...]")
      subopt['remove'] = OptionParser.new("#{File.basename($0)} remove content1 [content2 ...]")
      subopt['list'] = OptionParser.new("#{File.basename($0)} list")
      subopt['rebuild'] = OptionParser.new("#{File.basename($0)} rebuild")
      subopt['dump'] = OptionParser.new("#{File.basename($0)} dump")

      opt.order!(arguments)
      subcommand = arguments.shift

      if (subopt[subcommand])
        subopt[subcommand].parse!(arguments) unless arguments.empty?

        db_dir = select_dbdir(subcommand, init_default)
        obj = Cdstk.new(stdout, db_dir)

        case subcommand
        when 'init'
          FileUtils.mkdir_p db_dir if (init_default)
          obj.init 
        when 'update'
          obj.update
        when 'add'
          obj.add *arguments
        when 'remove'
          obj.remove *arguments
        when 'list'
          obj.list
        when 'rebuild'
          obj.rebuild
        when 'dump'
          obj.dump
        end
      else
        if subcommand
          $stderr.puts "#{File.basename($0)}: '#{subcommand}' is not a #{File.basename($0)} command. See '#{File.basename($0)} --help'"
        else
          stdout.puts opt.help
        end
      end
    end

    private

    def self.select_dbdir(subcommand, init_default)
      if (subcommand == 'init')
        if (init_default)
          db_default_dir
        else
          '.'
        end
      else
        if (dbdir?('.') || !dbdir?(db_default_dir))
          '.'
        else
          db_default_dir
        end
      end
    end
  end
end
