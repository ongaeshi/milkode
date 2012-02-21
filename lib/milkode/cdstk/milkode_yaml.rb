# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/02/21

require 'yaml'
require 'pathname'
require 'milkode/common/util'
require 'milkode/cdstk/package'

module Milkode
  class MilkodeYaml
    MILKODE_YAML_VERSION = '0.2'

    EMPTY_YAML = <<EOF
---
version: '#{MILKODE_YAML_VERSION}'
contents: []
EOF

    attr_reader :contents
    
    def initialize(str = nil)
      @data = YAML.load(str || EMPTY_YAML)
      @contents = parse_contents
    end

    def dump
      YAML.dump(@data)
    end

    def version
      @data['version']
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

