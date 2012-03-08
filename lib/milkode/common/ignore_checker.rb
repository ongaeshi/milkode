# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/02

require 'milkode/common/ignore_setting.rb'

module Milkode
  #
  # Sample:
  #   c = IgnoreChecker.new
  #   c.add IgnoreSetting.new("/", ["/rdoc", "/test/data", "*.lock"])
  #   c.add IgnoreSetting.new("/pkg", ["*.gem"])
  #   c.ignore?('/lib/test.rb')  #=> false
  #   c.ignore?('/pkg/hoge.gem') #=> true
  #
  class IgnoreChecker
    attr_reader :settings
    
    def initialize
      @settings = []
    end

    def add(setting)
      @settings << setting
    end

    def ignore?(path)
      @settings.any?{|s| s.ignore? path }
    end
  end
end
