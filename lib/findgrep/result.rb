# -*- coding: utf-8 -*-
require 'find'
require File.join(File.dirname(__FILE__), '../common/util')
include Gren

module FindGrep
  class Result
    attr_accessor :count
    attr_accessor :search_count
    attr_accessor :match_file_count
    attr_accessor :match_count
    attr_accessor :size
    attr_accessor :search_size
    
    attr_accessor :search_files
    attr_accessor :match_files
    attr_accessor :unreadable_files
    attr_accessor :prune_dirs
    attr_accessor :ignore_files

    def initialize(start_dir)
      @start_dir = File.expand_path(start_dir)
      @count, @search_count, @match_file_count, @match_count, @size, @search_size = 0, 0, 0, 0, 0, 0
      @start_time = Time.now
      @search_files, @match_files, @unreadable_files, @prune_dirs, @ignore_files  = [], [], [], [], []
    end

    def time_stop
      @end_time = Time.now
    end

    def time
      @end_time - @start_time 
    end

    def print(stdout)
      stdout.puts "dir   : #{@start_dir} (#{Util::time_s(time)})"
      stdout.puts "files : #{@search_count} in #{@count} (#{Util::size_s(@search_size)} in #{Util::size_s(@size)})"
      stdout.puts "match : #{@match_file_count} files, #{match_count} hit"
    end

  end
end
