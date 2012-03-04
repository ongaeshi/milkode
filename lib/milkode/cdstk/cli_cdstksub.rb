# -*- coding: utf-8 -*-
require 'optparse'
require 'milkode/cdstk/cdstk'
require 'milkode/common/dbdir.rb'
require 'milkode/cdweb/cli_cdweb'
include Milkode

module Milkode
  class CLI_Cdstksub
    def self.setup_init
      options = {:init_default => false}
      
      opt = OptionParser.new("#{File.basename($0)} init [db_dir]")
      opt.on('--default', 'Init default db, ENV[\'MILKODE_DEFAULT_DIR\'] or ~/.milkode.') { options[:init_default] = true }
      opt.on('-s', '--setdb', 'With setdb.') { options[:setdb] = true }

      return opt, options
    end

    def self.setup_add
      bin = File.basename($0)
      
      options = {}

      opt = OptionParser.new(<<EOF)
#{bin} add dir1 [dir2 ...]
usage:
  #{bin} add /path/to/dir1
  #{bin} add /path/to/dir2 /path/to/dir3
  #{bin} add /path/is/*
  #{bin} add /path/to/zipfile.zip
  #{bin} add /path/to/addon.xpi
  #{bin} add http://example.com/urlfile.zip

option:
EOF
      # opt.on('-n NAME', '--name NAME', 'Specify name (default: File.basename(dir))') {|v| options[:name] = v }
      opt.on('--no-auto-ignore', 'Disable auto ignore (Find ".gitignore")') { options[:no_auto_ignore] = true }
      opt.on('-v', '--verbose', 'Be verbose.')   { options[:verbose] = true }

      return opt, options
    end

    def self.setup_update
      options = {:force => false}

      opt = OptionParser.new("#{File.basename($0)} update [keyword1 keyword2 ...]")
      opt.on('--all', 'Update all.') { options[:all] = true }
      opt.on('-v', '--verbose', 'Be verbose.') { options[:verbose] = true }

      return opt, options
    end

    def self.setup_remove
      options = {:force => false}

      opt = OptionParser.new("#{File.basename($0)} remove keyword1 [keyword2 ...]")
      opt.on('--all', 'Update all.') { options[:all] = true }
      opt.on('-f', '--force',   'Force remove.') { options[:force] = true }
      opt.on('-v', '--verbose', 'Be verbose.')   { options[:verbose] = true }

      return opt, options
    end

    def self.setup_list
      options = {:verbose => false}

      opt = OptionParser.new("#{File.basename($0)} list package1 [package2 ...]") # @todo コメント修正
      opt.on('-v', '--verbose', 'Be verbose.') { options[:verbose] = true }

      return opt, options
    end

    def self.setup_pwd
      options = {:default => false}

      opt = OptionParser.new("#{File.basename($0)} pwd package1 [package2 ...]")
      opt.on('--default', 'Show default db, ENV[\'MILKODE_DEFAULT_DIR\'] or ~/.milkode.') { options[:default] = true }

      return opt, options
    end

    def self.setup_cleanup
      options = {:verbose => false, :force => false}
      
      opt = OptionParser.new("#{File.basename($0)} cleanup")
      opt.on('-f', '--force', 'Force cleanup.') { options[:force] = true }

      return opt, options
    end

    def self.setup_rebuild
      options = {}
      
      opt = OptionParser.new("#{File.basename($0)} keyword1 [keyword2 ...]")
      opt.on('--all', 'Rebuild all.') { options[:all] = true}
      opt.on('-v', '--verbose', 'Be verbose.') { options[:verbose] = true }

      return opt, options
    end

    def self.setup_web
      options = {
        :environment => ENV['RACK_ENV'] || "development",
        :pid         => nil,
        :Port        => 9292,
        :Host        => "127.0.0.1",
        :AccessLog   => [],
        :config      => "config.ru",
        # ----------------------------
        :server      => "thin",
        :LaunchBrowser => true,
        :DbDir => Milkode::CLI_Cdweb::select_dbdir,
      }
      
      opts = OptionParser.new("#{File.basename($0)} web")
      opts.on('--db DB_DIR', 'Database dir (default : current_dir)') {|v| options[:DbDir] = v }
      opts.on("-o", "--host HOST", "listen on HOST (default: 127.0.0.1)") {|host| options[:Host] = host }
      opts.on('-p', '--port PORT', 'use PORT (default: 9292)') {|v| options[:Port] = v }
      opts.on("-s", "--server SERVER", "serve using SERVER (default : thin)") {|s| options[:server] = s }
      opts.on('-n', '--no-browser', 'No launch browser.') {|v| options[:LaunchBrowser] = false }
      
      # --hostが'-h'を上書きするので、'-h'を再定義してあげる
      opts.on_tail("-h", "-?", "--help", "Show this message") do
        puts opts
        exit
      end
      
      return opts, options
    end

    def self.setup_dir
      options = {}
      
      opt = OptionParser.new("#{File.basename($0)} dir")
      opt.on('--top', 'XXX') {|v| options[:top] = true }

      return opt, options
    end

    def self.setup_setdb
      options = {}
      
      opt = OptionParser.new("#{File.basename($0)} setdb")
      opt.on('--reset', 'Reset default db.') {|v| options[:reset] = true }

      return opt, options
    end

    def self.setup_mcd
      options = {}
      
      opt = OptionParser.new("#{File.basename($0)} mcd")

      return opt, options
    end

    def self.setup_info
      options = {}
      
      opt = OptionParser.new("#{File.basename($0)} info")

      return opt, options
    end

    def self.setup_ignore
      bin = File.basename($0)
      
      options = {}

      opt = OptionParser.new("#{File.basename($0)} ignore [ignore_dir]")
      opt.on('-d', '--delete', 'Delete ignore') { options[:delete] = true }
      opt.on('--delete-all', 'Delete all') { options[:delete_all] = true }

      return opt, options
    end


  end
end
