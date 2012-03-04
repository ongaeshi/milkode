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
---
version: '0.2'
contents:
- directory: /a/dir1
- directory: /path/to/dir
  ignore:
  - ! '*.bak'
  - /rdoc
- directory: /a/b/c
EOF

  V_0_1 = <<EOF
---
version: 0.1
contents:
- directory: /a/dir1
- directory: /path/to/dir
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
    obj = MilkodeYaml.new
    assert_equal [], obj.contents

    obj = MilkodeYaml.new(SRC)
    assert_equal 3, obj.contents.size
    assert_equal "/path/to/dir", obj.contents[1].directory
    assert_equal 2, obj.contents[1].ignore.size
    assert_equal "/rdoc", obj.contents[1].ignore[1]
  end

  def test_add
    obj = MilkodeYaml.new
    obj.add(Package.create("/path/to/dir", []))

    assert_equal 1, obj.contents.size

    assert_equal <<EOF, obj.dump
---
version: '0.2'
contents:
- directory: /path/to/dir
  ignore: []
EOF
  end

  def test_remove
    obj = MilkodeYaml.new(SRC)
    obj.remove(obj.find_name("c"))

    assert_equal 2, obj.contents.size

    assert_equal <<EOF, obj.dump
---
version: '0.2'
contents:
- directory: /a/dir1
- directory: /path/to/dir
  ignore:
  - ! '*.bak'
  - /rdoc
EOF
  end

  def test_migrate
    obj = MilkodeYaml.new(SRC)
    assert_equal false, obj.migrate

    obj = MilkodeYaml.new(V_0_1)
    assert_equal true, obj.migrate

    assert_equal <<EOF, obj.dump
---
version: '0.2'
contents:
- directory: /a/dir1
- directory: /path/to/dir
EOF
    
  end

  def test_find_name
    obj = MilkodeYaml.new(SRC)
    assert_not_nil obj.find_name('dir')
    assert_nil obj.find_name('not')
  end

  def test_update
    obj = MilkodeYaml.new(SRC)

    p = obj.find_name('dir')
    p = Package.create(p.directory, p.ignore + ['*.a'])
    obj.update(p)

    assert_equal <<EOF, obj.dump
---
version: '0.2'
contents:
- directory: /a/dir1
- directory: /path/to/dir
  ignore:
  - ! '*.bak'
  - /rdoc
  - ! '*.a'
- directory: /a/b/c
EOF

    p = Package.create("not_found")
    assert_raise(RuntimeError) { obj.update(p) }
  end

  def test_find_dir
    obj = MilkodeYaml.new(SRC)
    assert_not_nil obj.find_dir('/path/to/dir')
  end

  def test_package_root
    obj = MilkodeYaml.new(SRC)
    assert_equal nil           , obj.package_root('/not_dir')
    assert_equal "/a/dir1"     , obj.package_root('/a/dir1/dir3').directory
    assert_equal nil           , obj.package_root('/hoge/a/dir1/dir3')
    assert_equal '/path/to/dir', obj.package_root('/path/to/dir').directory
  end
end
