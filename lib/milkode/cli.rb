# -*- coding: utf-8 -*-
require 'thor'
require 'milkode/cdstk/cdstk'
require 'milkode/common/dbdir.rb'
require 'milkode/cdweb/cli_cdweb'

module Milkode
  class CLI < Thor
    desc "init [db_dir]", "Initialize database directory. If db_dir is omitted"
    option :setdb, :type => :boolean, :aliases => '-s', :desc => 'Run setdb after initialization.'
    def init(db_dir = nil)
      db_dir = db_dir || Dbdir.default_dir
      FileUtils.mkdir_p db_dir
      cdstk(db_dir).init(options)
    end

    desc "add PATH", "Add package(s) to milkode"
    option :ignore, :type => :array, :aliases => '-i', :desc => 'Ignore path.'
    option :no_auto_ignore, :type => :boolean, :desc => 'Disable auto ignore (.gitignore).'
    option :verbose, :type => :boolean, :aliases => '-v', :desc => 'Be verbose.'
    def add(*args)
      cdstk.add(args, options)
    end

    desc "update [keyword1 keyword2 ...]", "Update database"
    option :all, :type => :boolean, :desc => "Update all."
    option :force, :type => :boolean, :aliases => '-f', :desc => 'Force update.'
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
    def list(*args)
      cdstk.list(args, options)
    end

    desc "pwd", "Display the current database"
    option :default, :type => :boolean, :desc => 'Show default db, ENV[\'MILKODE_DEFAULT_DIR\'] or ~/.milkode.'
    def pwd()
      cdstk.pwd(options)
    end

    desc "cleanup", "Creanup garbage recoeds"
    option :force, :type => :boolean, :aliases => '-f'
    def cleanup
      cdstk.cleanup(options)
    end

    desc "rebuild [keyword1 keyword2]", "Rebuild database"
    option :all, :type => :boolean, :desc => 'Remove all.'
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

    desc "info", "Information of milkode status"
    def info
      cdstk.info
    end

    desc "ignore [path ...]", "Ignore a file or directory"
    option :package, :aliases => '-p', :desc => "Package to ignore."
    option :delete, :type => :boolean, :aliases => '-d'
    option :delete_all, :type => :boolean
    option :dry_run, :type => :boolean, :aliases => '-n'
    def ignore(*paths)
      begin
        cdstk.ignore(paths, options)
      rescue IgnoreError => e
        STDOUT.puts e.message
      end
    end

    desc "web", "Startup web interface"
    option :db, :default => Milkode::CLI_Cdweb::select_dbdir
    option :host, :default => '127.0.0.1', :aliases => '-o'
    option :port, :default => 9292, :aliases => '-p'
    option :server, :default => 'thin', :aliases => '-s'
    option :no_browser, :default => 'false', :type => :boolean, :desc => 'Do not launch browser.'
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
        :server      => options[:server],
        :LaunchBrowser => ! options[:no_browser],
        :DbDir => options[:db],
      }
      opts[:customize] = options[:customize]
      cdstk(opts[:DbDir]).assert_compatible
      Milkode::CLI_Cdweb.execute_with_options(STDOUT, opts)
    end
  end

  private

  def cdstk(dir = nil)
    Cdstk.new(STDOUT, dir || db_dir)
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
