# -*- coding: utf-8 -*-
require 'optparse'
require 'codestock/cdstk/cdstk'
require 'codestock/common/dbdir.rb'
require 'codestock/cdweb/cli_cdweb'
include CodeStock

module CodeStock
  class CLI_Cdstk
    def self.execute(stdout, arguments=[])
      opt = OptionParser.new <<EOF
#{File.basename($0)} COMMAND [ARGS]

The most commonly used #{File.basename($0)} are:
  init        Init db.
  add         Add packages.
  update      Update packages.
  web         Run web-app.
  remove      Remove packages.
  list        List packages. 
  pwd         Disp current db.
  cleanup     Cleanup garbage records, packages.
  rebuild     Rebuild db.
  dump        Dump records.
EOF

      subopt = Hash.new
      suboptions = Hash.new
      
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
      
      subopt['pwd'] = OptionParser.new("#{File.basename($0)} pwd")

      subopt['cleanup'], suboptions['cleanup'] = setup_cleanup

      subopt['rebuild'] = OptionParser.new("#{File.basename($0)} rebuild")

      subopt['dump'] = OptionParser.new("#{File.basename($0)} dump")

      subopt['web'], suboptions['web'] = setup_web

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
          obj.add(arguments)
        when 'remove'
          obj.remove(arguments, remove_options[:force], remove_options[:verbose])
        when 'list'
          obj.list(arguments, list_options[:verbose])
        when 'pwd'
          obj.pwd
        when 'cleanup'
          obj.cleanup(suboptions[subcommand])
        when 'rebuild'
          obj.rebuild
        when 'dump'
          obj.dump
        when 'web'
          CodeStock::CLI_Cdweb.execute_with_options(stdout, suboptions[subcommand])
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

    def self.setup_cleanup
      options = {:verbose => false, :force => false}
      
      opt = OptionParser.new("#{File.basename($0)} cleanup")
      opt.on('-f', '--force', 'Force cleanup.') { options[:force] = true }
      opt.on('-v', '--verbose', 'Be verbose.')  { options[:verbose] = true }

      return opt, options
    end

    def self.setup_web
      options = {
        :environment => ENV['RACK_ENV'] || "development",
        :pid         => nil,
        :Port        => 9292,
        :Host        => "0.0.0.0",
        :AccessLog   => [],
        :config      => "config.ru",
        # ----------------------------
        :server      => "thin",
        :LaunchBrowser => true,
        :DbDir => CodeStock::CLI_Cdweb::select_dbdir,
      }
      
      opts = OptionParser.new("#{File.basename($0)} web")
      opts.on('--db DB_DIR', 'Database dir (default : ~/.codestock)') {|v| options[:DbDir] = v }
      opts.on("-o", "--host HOST", "listen on HOST (default: 0.0.0.0)") {|host| options[:Host] = host }
      opts.on('-p', '--port PORT', 'use PORT (default: 9292)') {|v| options[:Port] = v }
      opts.on('-n', '--no-browser', 'No launch browser.') {|v| options[:LaunchBrowser] = false }
      
      # --hostが'-h'を上書きするので、'-h'を再定義してあげる
      opts.on_tail("-h", "-?", "--help", "Show this message") do
        puts opts
        exit
      end
      
      return opts, options
    end
  end
end
