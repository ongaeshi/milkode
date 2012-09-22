# -*- coding: utf-8 -*-
require 'thor'
require 'milkode/cdstk/cdstk'
require 'milkode/common/dbdir.rb'
require 'milkode/cdweb/cli_cdweb'
require 'milkode/grep/cli_grep'

module Milkode
  class CLI < Thor
    class_option :help,    :type => :boolean, :aliases => '-h', :desc => 'Help message.'
    class_option :version, :type => :boolean, :aliases => '-v', :desc => 'Show version.'

    desc "init [db_dir]", "Initialize database directory. If db_dir is omitted"
    option :default, :type => :boolean, :desc => "Init default db, ENV['MILKODE_DEFAULT_DIR'] or ~/.milkode."
    option :setdb, :type => :boolean, :aliases => '-s', :desc => 'Run setdb after initialization.'
    def init(db_dir = nil)
      db_dir = db_dir || Dbdir.default_dir
      FileUtils.mkdir_p db_dir
      cdstk(db_dir).init(options)
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
    option :no_auto_ignore, :type => :boolean, :aliases => '-n', :desc => 'Disable auto ignore (.gitignore).'
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    
    def add(*args)
      if args.empty?
        CLI.task_help(shell, "add")
      else
        cdstk.add(args, options)
      end
    end

    desc "update [keyword1 keyword2 ...]", "Update database"
    option :all, :type => :boolean, :desc => "Update all."
    option :no_clean, :type => :boolean, :desc => "No cleanup."
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    def update(*args)
      cdstk.update(args, options)
    end

    desc "remove keyword1 [keyword2 ...]", "Remove package"
    option :all, :type => :boolean, :desc => 'Remove all.'
    option :force, :type => :boolean, :aliases => '-f', :desc => 'Force remove.'
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    def remove(*args)
      cdstk.remove(args, options)
    end

    desc "list [package1 package2 ...]", "List package"
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    option :check, :type => :boolean, :aliases => '-c', :desc => "Check integrity 'yaml and database'"
    def list(*args)
      cdstk.list(args, options)
    end

    desc "pwd", "Display the current database"
    option :default, :type => :boolean, :desc => 'Show default db, ENV[\'MILKODE_DEFAULT_DIR\'] or ~/.milkode.'
    def pwd()
      cdstk.pwd(options)
    end

    desc "cleanup", "Creanup garbage recoeds"
    option :force, :type => :boolean, :aliases => '-f', :desc => 'Force cleanup.'
    def cleanup
      cdstk.cleanup(options)
    end

    desc "rebuild [keyword1 keyword2]", "Rebuild database"
    option :all, :type => :boolean, :desc => 'Rebuild all.'
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    def rebuild(*args)
      cdstk.rebuild(args, options)
    end

    desc "dump", "Dump records"
    def dump
      cdstk.dump
    end

    desc "dir [package1 package2]", "Print project root directory"
    option :top, :type => :boolean
    def dir(*args)
      cdstk.dir(args, options)
    end

    desc "setdb [dbpath]", "Set default db to dbpath"
    option :reset, :type => :boolean, :aliases => '--default', :desc => 'Reset to the system default database.'
    def setdb(dbpath = nil)
      cdstk.setdb(dbpath, options)
    end

    desc "mcd", "Generate `mcd' command"
    option :shell, :desc => 'Type of shell. bash or cygwin'
    def mcd
      cdstk.mcd(options)
    end

    desc "info [package]", "Display package information"
    option :all, :type => :boolean, :aliases => '-a', :desc => 'Summary'
    def info(*args)
      cdstk.info(args, options)
    end

    desc "ignore [path ...]", "Ignore a file or directory"
    option :package, :aliases => '-p', :desc => "Package to ignore."
    option :delete, :type => :boolean, :aliases => '-d', :desc => "Delete ignore setting."
    option :delete_all, :type => :boolean, :desc => "Delete all ignore setting."
    option :dry_run, :type => :boolean, :aliases => '-n', :desc => "Ignore setting test."
    def ignore(*paths)
      begin
        cdstk.ignore(paths, options)
      rescue IgnoreError => e
        $stdout.puts e.message
      end
    end

    desc "fav [package1 package2 ...]", "Add favorite"
    option :delete, :type => :boolean, :aliases => '-d', :desc => "Delete favorite."
    def fav(*paths)
      cdstk.fav(paths, options)
    end

    desc "web", "Startup web interface"
    option :db, :default => Milkode::CLI_Cdweb::select_dbdir
    option :host, :default => '127.0.0.1', :aliases => '-o'
    option :port, :default => 9292, :aliases => '-p'
    option :server, :default => 'thin', :aliases => '-s'
    option :no_browser, :type => :boolean, :default => false, :aliases => '-n', :type => :boolean, :desc => 'Do not launch browser.'
    option :customize, :type => :boolean, :desc => 'Create customize file.'
    def web
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

    desc "grep", "Search projects"
    long_desc "Search projects. See `milk grep -h` for detail."
    def grep(*args)
      Milkode::CLI_Grep.execute($stdout, args)
    end

    desc "plugins", "Display plugins"
    long_desc "Display plugin list."
    def plugins(*args)
      $stdout.puts <<EOF
Gitomb              https://github.com/tomykaira/gitomb
redmine_milkode     https://github.com/suer/redmine_milkode
Milkode_Sublime     https://github.com/tsurushuu/Milkode_Sublime
emacs-milkode       https://github.com/ongaeshi/emacs-milkode
EOF
    end

    # --------------------------------------------------------------------------
    
    no_tasks do
      def shell
        @shell ||= Thor::Base.shell.new
      end

      # デフォルトメソッドを上書きして -h を処理
      # defined in /lib/thor/invocation.rb
      def invoke_task(task, *args)
        if options[:help] && task.name != 'grep'
          CLI.task_help(shell, task.name)
        elsif options[:version] && task.name == 'help'
          puts "milk #{Version}"
        else
          super
        end
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
