# -*- coding: utf-8 -*-
require 'thor'
require 'milkode/cdstk/cdstk'
require 'milkode/common/dbdir.rb'

module Milkode
  class CLI < Thor
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
