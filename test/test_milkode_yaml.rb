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

  EMPTY = <<EOF
---
version: '0.2'
contents: []
EOF

  SRC = <<EOF
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

  def test_dump
    obj = MilkodeYaml.new(SRC)
    assert_equal SRC, obj.dump
  end

  def test_version
    obj = MilkodeYaml.new(SRC)
    assert_equal '0.2', obj.version
  end

  def test_contents
    obj = MilkodeYaml.new(EMPTY)
    assert_equal [], obj.contents

    obj = MilkodeYaml.new(SRC)
    assert_equal 3, obj.contents.size
    assert_equal "/path/to/dir", obj.contents[1].dir
    assert_equal 2, obj.contents[1].ignore.size
    assert_equal "/rdoc", obj.contents[1].ignore[1]
  end
end
