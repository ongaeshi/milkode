# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/05/04

module Milkode
  class InfoHome
    attr_reader :record_content

    def initialize
      packages       = Database.instance.packages(nil)

      @record_content = packages.map do |name|
        "<dt class='result-file'><img src='/images/info.png' /><a href='/info/#{name}'>#{name}</a></dt>"
      end.join("\n")
    end

  end
end

