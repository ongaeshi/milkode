# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require File.join(File.dirname(__FILE__), "test_helper.rb")
require File.join(File.dirname(__FILE__), "../lib/cdstk/cdstk_yaml.rb")
require 'fileutils'

class TestCdstkYaml < Test::Unit::TestCase
  include CodeStock

  def setup
    @prev_dir = Dir.pwd
    @tmp_dir = Pathname(File.dirname(__FILE__)) + "tmp"
    FileUtils.rm_rf(@tmp_dir.to_s)
    FileUtils.mkdir_p(@tmp_dir.to_s)
    FileUtils.cd(@tmp_dir.to_s)
  end

  def test_000
    # create
    yaml = CdstkYaml.create
    assert_equal yaml.contents, []
    assert_equal yaml.version, 0.1
    assert_raise(CdstkYaml::YAMLAlreadyExist) { CdstkYaml.create }

    # load
    yaml = CdstkYaml.load
    assert_equal yaml.contents, []
    assert_equal yaml.version, 0.1

    # load fail
    FileUtils.mkdir 'loadtest'
    FileUtils.cd 'loadtest' do
      assert_raise(CdstkYaml::YAMLNotExist) { CdstkYaml.load }
    end

    # add
    yaml.add('dir1')
    yaml.add('dir2', 'dir3')
    assert_equal ['dir1', 'dir2', 'dir3'], yaml.directorys

    # remove
    yaml.add('dir2', 'dir4', 'dir5')
    yaml.remove('dir5')
    yaml.remove('dir2', 'dir3')
    assert_equal ['dir1', 'dir4'], yaml.directorys

    # save
    yaml.save
    assert_equal <<EOF, open('grendb.yaml').read
--- 
version: 0.1
contents: 
- directory: dir1
- directory: dir4
EOF
  end

  def test_001
    FileUtils.mkdir 'otherpath'
    
    # create
    yaml = CdstkYaml.create('otherpath')
    assert_equal yaml.contents, []
    assert_equal yaml.version, 0.1
    assert_raise(CdstkYaml::YAMLAlreadyExist) { CdstkYaml.create('otherpath') }

    # load
    yaml = CdstkYaml.load 'otherpath'
    assert_equal yaml.contents, []
    assert_equal yaml.version, 0.1

    # load fail
    FileUtils.mkdir 'loadtest'
    FileUtils.cd 'loadtest' do
      assert_raise(CdstkYaml::YAMLNotExist) { CdstkYaml.load }
    end

    # add
    yaml.add('dir1')
    yaml.add('dir2', 'dir3')
    assert_equal ['dir1', 'dir2', 'dir3'], yaml.directorys

    # remove
    yaml.add('dir2', 'dir4', 'dir5')
    yaml.remove('dir5')
    yaml.remove('dir2', 'dir3')
    assert_equal ['dir1', 'dir4'], yaml.directorys

    # save
    yaml.save
    assert_equal <<EOF, open('otherpath/grendb.yaml').read
--- 
version: 0.1
contents: 
- directory: dir1
- directory: dir4
EOF
  end
  
  def teardown
    FileUtils.cd(@prev_dir)
    FileUtils.rm_rf(@tmp_dir.to_s)
  end
end
