# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'test_helper'
require 'codestock/cdstk/cdstk_yaml.rb'
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
    yaml.remove(CdstkYaml::Query.new ['dir5'])
    yaml.remove(CdstkYaml::Query.new ['dir2', 'dir3'])
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
    yaml.remove(CdstkYaml::Query.new ['dir5'])
    yaml.remove(CdstkYaml::Query.new ['dir2', 'dir3'])
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

  def test_query
    d = 'directory'
    
    contents = [{d => 'key'}, {d => 'keyword'}, {d => 'not'}]

    query = CdstkYaml::Query.new(['key'])
    assert_equal [{d => 'key'}, {d => 'keyword'}], query.select(contents)

    query = CdstkYaml::Query.new(['word'])
    assert_equal [{d => 'keyword'}], query.select(contents)

    contents = [{d => 'a/dir'}, {d => 'b/dia'}]
    query = CdstkYaml::Query.new(['a'])
    assert_equal [{d => 'b/dia'}], query.select(contents) # ディレクトリ名は含めない
  end

  def test_list
    src = <<EOF
version: 0.1
contents: 
- directory: /a/dir1
- directory: /b/dir4
EOF

    yaml = CdstkYaml.new('dummy.yaml', YAML.load(src))
    assert_equal ['dir1', 'dir4'], yaml.list
    assert_equal ['/a/dir1', '/b/dir4'], yaml.list(nil, true)
    assert_equal ['dir4'], yaml.list(CdstkYaml::Query.new(['4']), false)
    assert_equal [], yaml.list(CdstkYaml::Query.new(['a']), true)
    assert_equal ['dir1', 'dir4'], yaml.list(nil)
  end

  def test_remove
    src = <<EOF
version: 0.1
contents: 
- directory: /a/dir1
- directory: /b/dir4
EOF

    yaml = CdstkYaml.new('dummy.yaml', YAML.load(src))

    yaml.remove(CdstkYaml::Query.new(['dir4']))
    assert_equal ['dir1'], yaml.list

    yaml.remove(CdstkYaml::Query.new(['dir1']))
    assert_equal [], yaml.list

    # ---

    yaml = CdstkYaml.new('dummy.yaml', YAML.load(src))

    yaml.remove(CdstkYaml::Query.new(['dir1']))
    assert_equal ['dir4'], yaml.list

    yaml.remove(CdstkYaml::Query.new([]))
    assert_equal ['dir4'], yaml.list

  end
  
  def teardown
    FileUtils.cd(@prev_dir)
    FileUtils.rm_rf(@tmp_dir.to_s)
  end
end
