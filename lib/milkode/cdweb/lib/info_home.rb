# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/05/04

module Milkode
  class InfoHome
    attr_reader :record_content
    attr_reader :total_records

    def initialize
      packages       = Database.instance.packages(nil)
      @total_records = packages.size      
      
      @record_content = packages.map {|name|
        "<dt class='result-file'><a href='/info/#{name}'>#{name}</a></dt>"
      }.join
    end
  end
end

