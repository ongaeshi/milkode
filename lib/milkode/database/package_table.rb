# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/05/29

require 'milkode/common/util'

module Milkode
  class PackageTable
    include Enumerable

    def self.define_schema
      Groonga::Schema.define do |schema|
        schema.create_table("packages", :type => :hash) do |table|
          table.string("name")
          table.string("directory")
          table.time("addtime")
          table.time("updatetime")
          table.time("viewtime")
          table.time("favtime")
        end
      end
    end

    def initialize(table)
      @table = table
    end

    def size
      @table.size
    end

    def add(name, directory, options)
       now = Time.now
      @table.add(name,
                 :name       => name,
                 :directory  => directory,
                 :addtime    => now,
                 :updatetime => options[:same_add] ? now : Time.at(0),
                 :viewtime   => options[:same_add] ? now : Time.at(0),
                 :favtime    => options[:fav] ? now : Time.at(0))
    end

    def remove(name)
      @table[name].delete
    end

    def remove_all
      self.each do |r|
        remove(r.name)
      end
    end

    def [](name)
      @table[name]
    end

    def each
      @table.select.each do |r|
        yield r
      end
    end

    def sort(kind, order = "descending")
      Util.groonga_table_sort(@table, [{:key => kind, :order => order}])
    end

    def dump
      self.each do |r|
        p [r.name, r.addtime, r.updatetime, r.viewtime, r.favtime]
      end
    end

    def touch(name, kind, time = Time.now)
      @table[name][kind] = time
    end

    def touch_if(name, kind, time = Time.now)
      record = @table[name]

      if record
        record[kind] = time
      else
        nil
      end
    end

    def favs
      sorted = sort('favtime')
      zero_time = Time.at(0)
      index = sorted.find_index {|v| v.favtime == zero_time}
      unless index.nil?
        sorted[0...index]
      else
        sorted
      end
    end
  end
end


