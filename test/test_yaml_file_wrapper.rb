# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'test_helper'
require 'milkode/cdstk/yaml_file_wrapper.rb'
require 'milkode/cdstk/package'
require 'fileutils'

class TestYamlFileWrapper < Test::Unit::TestCase
  include Milkode

  def setup
    @prev_dir = Dir.pwd
    @tmp_dir = Pathname(File.dirname(__FILE__)) + "tmp"
    FileUtils.rm_rf(@tmp_dir.to_s)
    FileUtils.mkdir_p(@tmp_dir.to_s)
    FileUtils.cd(@tmp_dir.to_s)
  end

  def test_basic
    # create
    yaml = YamlFileWrapper.create
    assert_equal yaml.contents, []
    assert_equal yaml.version, '0.2'
    assert_raise(YamlFileWrapper::YAMLAlreadyExist) { YamlFileWrapper.create }

    # # load
    yaml = YamlFileWrapper.load
    assert_equal yaml.contents, []
    assert_equal yaml.version, '0.2'

    # load fail
    FileUtils.mkdir 'loadtest'
    FileUtils.cd 'loadtest' do
      assert_raise(YamlFileWrapper::YAMLNotExist) { YamlFileWrapper.load }
    end

    # add
    yaml.add(Package.create('/path/to/dir1'))
    yaml.add(Package.create('/path/to/dir2'))
    yaml.add(Package.create('/path/to/dir3'))
    assert_equal ['dir1', 'dir2', 'dir3'], yaml.contents.map{|v| v.name }

    # remove
    yaml.remove(Package.create('/path/to/dir2'))
    assert_equal ['dir1', 'dir3'], yaml.contents.map{|v| v.name }

    # update
    yaml.update(Package.create('/path/to/dir1', ["*.bak"]))
    assert_equal ['*.bak'], yaml.contents[0].ignore

    # find_name
    assert yaml.find_name('dir1')
    assert_nil yaml.find_name('dir2')

    # find_dir
    assert yaml.find_dir('/path/to/dir1')
    assert_nil yaml.find_dir('/path/to/dir2')

    # save
    yaml.save
    r = open('milkode.yaml'){|f|f.read}
    assert_equal <<EOF, r
---
version: '0.2'
contents:
- directory: /path/to/dir1
  ignore:
  - ! '*.bak'
- directory: /path/to/dir3
EOF
  end

  def test_save_otherpath
    FileUtils.mkdir 'otherpath'
    yaml = YamlFileWrapper.create('otherpath')
    yaml.save
    
    # save
    r = open('otherpath/milkode.yaml'){|f|f.read}
    assert_equal <<EOF, r
---
version: '0.2'
contents: []
EOF
  end
  
  def teardown
    FileUtils.cd(@prev_dir)
    FileUtils.rm_rf(@tmp_dir.to_s)
  end
end
