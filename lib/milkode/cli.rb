# -*- coding: utf-8 -*-
require 'thor'
require 'milkode/cdstk/cdstk'
require 'milkode/common/dbdir.rb'
require 'milkode/cdweb/cli_cdweb'
require 'milkode/grep/cli_grep'

module Milkode
  class CLI < Thor
    desc "init [db_dir]", "Initialize database directory. If db_dir is omitted"
    option :default, :type => :boolean, :desc => "Init default db, ENV['MILKODE_DEFAULT_DIR'] or ~/.milkode."
    option :setdb, :type => :boolean, :aliases => '-s', :desc => 'Run setdb after initialization.'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def init(db_dir = nil)
      if options[:help]
        CLI.task_help(shell, "init")
      else
        db_dir = db_dir || Dbdir.default_dir
        FileUtils.mkdir_p db_dir
        cdstk(db_dir).init(options)
      end
    end

    desc "add PATH", <<EOF
Add package(s) to milkode

Samples:
  milk add /path/to/dir1
  milk add /path/to/dir2 /path/to/dir3
  milk add /path/is/*
  milk add /path/to/zipfile.zip
  milk add /path/to/addon.xpi
  milk add http://example.com/urlfile.zip
  milk add git://github.com/ongaeshi/milkode.git
EOF
    option :ignore, :type => :array, :aliases => '-i', :desc => 'Ignore path.'
    option :no_auto_ignore, :type => :boolean, :desc => 'Disable auto ignore (.gitignore).'
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def add(*args)
      if options[:help] || args.empty?
        CLI.task_help(shell, "add")
      else
        cdstk.add(args, options)
      end
    end

    desc "update [keyword1 keyword2 ...]", "Update database"
    option :all, :type => :boolean, :desc => "Update all."
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def update(*args)
      if options[:help]
        CLI.task_help(shell, "update")
      else
        cdstk.update(args, options)
      end
    end

    desc "remove keyword1 [keyword2 ...]", "Remove package"
    option :all, :type => :boolean, :desc => 'Remove all.'
    option :force, :type => :boolean, :aliases => '-f', :desc => 'Force remove.'
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def remove(*args)
      if options[:help]
        CLI.task_help(shell, "remove")
      else
        cdstk.remove(args, options)
      end
    end

    desc "list [package1 package2 ...]", "List package"
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def list(*args)
      if options[:help]
        CLI.task_help(shell, "list")
      else
        cdstk.list(args, options)
      end
    end

    desc "pwd", "Display the current database"
    option :default, :type => :boolean, :desc => 'Show default db, ENV[\'MILKODE_DEFAULT_DIR\'] or ~/.milkode.'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def pwd()
      if options[:help]
        CLI.task_help(shell, "pwd")
      else
        cdstk.pwd(options)
      end
    end

    desc "cleanup", "Creanup garbage recoeds"
    option :force, :type => :boolean, :aliases => '-f', :desc => 'Force cleanup.'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def cleanup
      if options[:help]
        CLI.task_help(shell, "cleanup")
      else
        cdstk.cleanup(options)
      end
    end

    desc "rebuild [keyword1 keyword2]", "Rebuild database"
    option :all, :type => :boolean, :desc => 'Rebuild all.'
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def rebuild(*args)
      if options[:help]
        CLI.task_help(shell, "rebuild")
      else
        cdstk.rebuild(args, options)
      end
    end

    desc "dump", "Dump records"
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def dump
      if options[:help]
        CLI.task_help(shell, "dump")
      else
        cdstk.dump
      end
    end

    desc "dir [package1 package2]", "Print project root directory"
    option :top, :type => :boolean
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def dir(*args)
      if options[:help]
        CLI.task_help(shell, "dir")
      else
        cdstk.dir(args, options)
      end
    end

    desc "setdb [dbpath]", "Set default db to dbpath"
    option :reset, :type => :boolean, :aliases => '--default', :desc => 'Reset to the system default database.'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def setdb(dbpath = nil)
      if options[:help]
        CLI.task_help(shell, "setdb")
      else
        cdstk.setdb(dbpath, options)
      end
    end

    desc "mcd", "Generate `mcd' command"
    option :shell, :desc => 'Type of shell. bash or cygwin'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def mcd
      if options[:help]
        CLI.task_help(shell, "mcd")
      else
        cdstk.mcd(options)
      end
    end

    desc "info", "Information of milkode status"
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def info
      if options[:help]
        CLI.task_help(shell, "info")
      else
        cdstk.info
      end
    end

    desc "ignore [path ...]", "Ignore a file or directory"
    option :package, :aliases => '-p', :desc => "Package to ignore."
    option :delete, :type => :boolean, :aliases => '-d', :desc => "Delete ignore setting."
    option :delete_all, :type => :boolean, :desc => "Delete all ignore setting."
    option :dry_run, :type => :boolean, :aliases => '-n', :desc => "Ignore setting test."
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def ignore(*paths)
      if options[:help]
        CLI.task_help(shell, "ignore")
      else
        begin
          cdstk.ignore(paths, options)
        rescue IgnoreError => e
          $stdout.puts e.message
        end
      end
    end

    desc "web", "Startup web interface"
    option :db, :default => Milkode::CLI_Cdweb::select_dbdir
    option :host, :default => '127.0.0.1', :aliases => '-o'
    option :port, :default => 9292, :aliases => '-p'
    option :server, :default => 'thin', :aliases => '-s'
    option :no_browser, :type => :boolean, :default => false, :aliases => '-n', :type => :boolean, :desc => 'Do not launch browser.'
    option :customize, :type => :boolean, :desc => 'Create customize file.'
    option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    def web
      if options[:help]
        CLI.task_help(shell, "web")
      else
        opts = {
          :environment => ENV['RACK_ENV'] || "development",
          :pid         => nil,
          :Port        => options[:port],
          :Host        => options[:host],
          :AccessLog   => [],
          :config      => "config.ru",
          # ----------------------------
          :server        => options[:server],
          :LaunchBrowser => !options[:no_browser],
          :DbDir         => options[:db],
        }
        opts[:customize] = options[:customize]
        cdstk(opts[:DbDir]).assert_compatible
        Milkode::CLI_Cdweb.execute_with_options($stdout, opts)
      end
    end

    desc "grep", "Search projects"
    long_desc "Search projects. See `milk grep -h` for detail."
    def grep(*args)
      Milkode::CLI_Grep.execute($stdout, args)
    end

    # --------------------------------------------------------------------------
    
    no_tasks do
      def shell
        @shell ||= Thor::Base.shell.new
      end
    end

    private

    def cdstk(dir = nil)
      Cdstk.new($stdout, dir || db_dir)
    end

    # init からはアクセスしてはいけない
    def db_dir
      if (Dbdir.dbdir?('.') || !Dbdir.dbdir?(Dbdir.default_dir))
        '.'
      else
        Dbdir.default_dir
      end
    end

  end
end
