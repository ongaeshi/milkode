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

    class Package
      def initialize(hash)
        @hash = hash
      end

      def self.create(dir, ignore)
        Package.new({"directory" => dir, "ignore" => ignore})
      end

      def directory
        @hash['directory']
      end

      alias :dir :directory

      def ignore
        @hash['ignore']
      end

      def hash
        @hash
      end
    end

    # パッケージの追加
    # @todo 重複チェック、別名で保存等
    def add(package)
      @contents.push package
      update_contents
    end

    # 名前で削除
    # @todo nameパラメーターに対応予定
    def delete_name(name)
      @contents.delete_if do |v|
        v.directory == name
      end
      update_contents
    end

    private

    def parse_contents
      @data['contents'].map do |v|
        Package.new(v)
      end
    end

    def update_contents
      @data['contents'] = @contents.map{|v| v.hash }
    end
  end
end

