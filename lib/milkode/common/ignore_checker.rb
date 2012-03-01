# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/02

require 'milkode/common/ignore_setting.rb'

module Milkode
  class IgnoreChecker
    attr_reader :settings
    
    def initialize(ignore_settings)
      @settings = ignore_settings
    end

    # ex.
    #   /lib/test.rb
    #   /pkg/test.gem
    def ignore?(path)
      false
    end
  end
end
