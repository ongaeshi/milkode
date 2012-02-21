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

    attr_reader :contents
    
    def initialize(str)
      @data = YAML.load(str)
      @contents = parse_contents
    end

    def dump
      YAML.dump(@data)
    end

    def version
      @data['version']
    end

    private

    class Package
      def initialize(hash)
        @hash = hash
      end

      def directory
        @hash['directory']
      end

      alias :dir :directory

      def ignore
        @hash['ignore']
      end 
    end

    def parse_contents
      @data['contents'].map do |v|
        Package.new(v)
      end
    end
  end
end

