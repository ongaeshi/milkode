# -*- coding: utf-8 -*-
require 'optparse'
require 'codestock/cdstk/cdstk'
require 'codestock/common/dbdir.rb'
include CodeStock

module CodeStock
  class CLI_Cdstk
    def self.execute(stdout, arguments=[])
      opt = OptionParser.new <<EOF
#{File.basename($0)} COMMAND [ARGS]

The most commonly used #{File.basename($0)} are:
  init        Init db.
  add         Add contents.
  update      Update contents.
  remove      Remove contents.
  list        List contents. 
  cleanup     Cleanup garbage (record, contents).
  rebuild     Rebuild db.
  dump        Dump contents.
EOF

      subopt = Hash.new
      
      init_default = false
      subopt['init'] = OptionParser.new("#{File.basename($0)} init")
      subopt['init'].on('--default', 'Init db default path, ENV[\'CODESTOCK_DEFAULT_DIR\'] or ~/.codestock.') { init_default = true }
      
      subopt['update'] = OptionParser.new("#{File.basename($0)} update content1 [content2 ...]")

      subopt['add'] = OptionParser.new("#{File.basename($0)} add dir1 [dir2 ...]")

      remove_options = {:force => false, :verbose => false}
      subopt['remove'] = OptionParser.new("#{File.basename($0)} remove content1 [content2 ...]")
      subopt['remove'].on('-f', '--force', 'Force remove.') { remove_options[:force] = true }
      subopt['remove'].on('-v', '--verbose', 'Be verbose.') { remove_options[:verbose] = true }

      list_options = {:verbose => false}
      subopt['list'] = OptionParser.new("#{File.basename($0)} list content1 [content2 ...]")
      subopt['list'].on('-v', '--verbose', 'Be verbose.') { list_options[:verbose] = true }

      cleanup_options = {:verbose => false}
      subopt['cleanup'] = OptionParser.new("#{File.basename($0)} cleanup")
      subopt['cleanup'].on('-v', '--verbose', 'Be verbose.') { cleanup_options[:verbose] = true }
      
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
          obj.update(arguments)
        when 'add'
          obj.add *arguments
        when 'remove'
          obj.remove(arguments, remove_options[:force], remove_options[:verbose])
        when 'list'
          obj.list(arguments, list_options[:verbose])
        when 'cleanup'
          obj.cleanup(cleanup_options[:verbose])
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
