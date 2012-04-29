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
