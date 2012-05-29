# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/05/29

module Milkode
  class PackageTable
    def initialize(table)
      @table = table
    end

    def size
      @table.size
    end

    def add(name)
      @table.add(name, :name => name, :addtime => Time.now)
    end

    def remove(name)
      @table[name].delete
    end

    def [](name)
      @table[name]
    end

    def each
      @table.select.each do |r|
        yield r
      end
    end

    def dump
      self.each do |r|
        p [r.name, r.addtime, r.updatetime, r.viewtime, r.favtime]
      end
    end
  end
end


