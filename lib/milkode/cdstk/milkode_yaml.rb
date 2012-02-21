# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/02/21

require 'yaml'
require 'pathname'
require 'milkode/common/util.rb'

module Milkode
  class MilkodeYaml
    MILKODE_YAML_VERSION = '0.2'
    
    def initialize(str)
      @data = YAML.load(str)
    end

    def dump
      YAML.dump(@data)
    end

    def version
      @data['version']
    end
  end
end

