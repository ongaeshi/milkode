# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'test_helper'
require 'milkode/cdstk/cdstk_yaml.rb'
require 'fileutils'

class TestCdstkYaml < Test::Unit::TestCase
  include Milkode

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
    yaml.add(['dir1'])
    yaml.add(['dir2', 'dir3'])
    assert_equal ['dir1', 'dir2', 'dir3'], yaml.directorys

    # remove
    yaml.add(['dir2', 'dir4', 'dir5'])
    yaml.remove(CdstkYaml::Query.new ['dir5'])
    yaml.remove(CdstkYaml::Query.new ['dir2', 'dir3'])
    assert_equal ['dir1', 'dir4'], yaml.directorys

    # save
    yaml.save
    r = YAML.load(open('milkode.yaml').read)
    assert_equal 0.1, r['version']
    assert_equal([{'directory'=>'dir1'}, {'directory' => 'dir4'}], r['contents'])
  end

  def test_001
    FileUtils.mkdir 'otherpath'
    yaml = CdstkYaml.create('otherpath')
    yaml.save
    
    # save
    r = YAML.load(open('otherpath/milkode.yaml').read)
    assert_equal 0.1, r['version']
    assert_equal([], r['contents'])
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
    assert_equal [{"directory"=>"/a/dir1"}, {"directory"=>"/b/dir4"}], yaml.list
    assert_equal [{"directory"=>"/b/dir4"}], yaml.list(CdstkYaml::Query.new(['4']))
    assert_equal [], yaml.list(CdstkYaml::Query.new(['a']))
    assert_equal [{"directory"=>"/a/dir1"}, {"directory"=>"/b/dir4"}], yaml.list(nil)
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
    assert_equal [{"directory"=>"/a/dir1"}], yaml.list

    yaml.remove(CdstkYaml::Query.new(['dir1']))
    assert_equal [], yaml.list

    # ---

    yaml = CdstkYaml.new('dummy.yaml', YAML.load(src))

    yaml.remove(CdstkYaml::Query.new(['dir1']))
    assert_equal [{"directory"=>"/b/dir4"}], yaml.list

    yaml.remove(CdstkYaml::Query.new([]))
    assert_equal [{"directory"=>"/b/dir4"}], yaml.list

  end

  def test_exist
    src = <<EOF
version: 0.1
contents: 
- directory: /a/dir1
- directory: /b/dir12
- directory: /b/dir4
EOF

    yaml = CdstkYaml.new('dummy.yaml', YAML.load(src))

    assert_not_nil yaml.exist?('dir1')
    assert_not_nil yaml.exist?('dir12')
    assert_nil yaml.exist?('dir123')
    assert_nil yaml.exist?('dir')
  end

  def test_package_root
    src = <<EOF
version: 0.1
contents: 
- directory: /a/dir1
- directory: /path/to/dir
- directory: /a/b/c
EOF

    yaml = CdstkYaml.new('dummy.yaml', YAML.load(src))

    assert_equal nil           , yaml.package_root('/not_dir')
    assert_equal "/a/dir1"     , yaml.package_root('/a/dir1/dir3')
    assert_equal nil           , yaml.package_root('/hoge/a/dir1/dir3')
    assert_equal '/path/to/dir', yaml.package_root('/path/to/dir')
  end
  
  def teardown
    FileUtils.cd(@prev_dir)
    FileUtils.rm_rf(@tmp_dir.to_s)
  end
end
