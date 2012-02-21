# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'test_helper'
require 'milkode/cdstk/milkode_yaml.rb'

class TestMilkodeYaml < Test::Unit::TestCase
  include Milkode

  SRC = <<EOF
version: '0.2'
contents: 
- directory: /a/dir1
  ignore: []
- directory: /path/to/dir
  ignore: ['*.bak', '/rdoc']
- directory: /a/b/c
  ignore: []
EOF

  def test_initialize
    obj = MilkodeYaml.new(SRC)

    assert_equal <<EOF, obj.dump
---
version: '0.2'
contents:
- directory: /a/dir1
  ignore: []
- directory: /path/to/dir
  ignore:
  - ! '*.bak'
  - /rdoc
- directory: /a/b/c
  ignore: []
EOF

  end

  def test_version
    obj = MilkodeYaml.new(SRC)
    assert_equal '0.2', obj.version
  end
end
