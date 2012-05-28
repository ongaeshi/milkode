# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/05/29

module Milkode
  class PackagesTable
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

    def get(name)
      @table[name]
    end

    def dump
      records = @table.select

      records.each do |r|
        p [r.name, r.addtime, r.updatetime, r.viewtime, r.favtime]
      end
    end
  end
end


