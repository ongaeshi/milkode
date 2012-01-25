# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'milkode/common/util'
require 'test/unit'
require 'file_test_utils'
require 'tmpdir'

class TestUtil < Test::Unit::TestCase
  include FileTestUtils

  def test_zip_extract
    Milkode::Util::zip_extract('../data/abc.zip', '.')
    assert File.exist?('abc')
    assert File.exist?('abc/a.txt')
    assert File.exist?('abc/b.txt')
    assert File.exist?('abc/c.txt')
    
    Milkode::Util::zip_extract('../data/nodir_abc.zip', '.')
    assert File.exist?('nodir_abc')
    assert File.exist?('nodir_abc/a.txt')
    assert File.exist?('nodir_abc/b.txt')
    assert File.exist?('nodir_abc/c.txt')
  end

  def test_root_entrylist
    assert_equal ['abc/'], Milkode::Util::root_entrylist('../data/abc.zip')
    assert_equal ['a.txt', 'b.txt', 'c.txt'], Milkode::Util::root_entrylist('../data/nodir_abc.zip')
  end

  def test_platform
    if (Milkode::Util::platform_osx?)
      assert_equal Milkode::Util::shell_kcode, Kconv::UTF8
    end

    if (Milkode::Util::platform_win?)
      assert_equal Milkode::Util::shell_kcode, Kconv::SJIS
    end
  end

  def create_filename_str(name)
    Dir.mktmpdir do |dir|
      FileUtils.touch( File.join(dir, name) )

      Dir.foreach(dir) do |f|
        next if (f == "." or f == "..")
        return f
      end
    end
  end

  def test_filename_to_utf8
    if (Milkode::Util::ruby19?)
      assert_equal Encoding::UTF_8, Milkode::Util::filename_to_utf8('ダミー').encoding
      assert_equal Encoding::UTF_8, Milkode::Util::filename_to_utf8(create_filename_str('ダミー')).encoding
    else
      # 実行だけはしておく
      Milkode::Util::filename_to_utf8('ダミー')
      Milkode::Util::filename_to_utf8(create_filename_str('ダミー'))
    end
  end

  def test_downcase?
    assert !Milkode::Util::downcase?("DUMMY")
    assert Milkode::Util::downcase?("dummy")    
    assert !Milkode::Util::downcase?("Dummy")
    assert !Milkode::Util::downcase?("dummyNode")    
  end

  def test_parse_gotoline
    assert_equal [['a', 'b'], 123],       Milkode::Util::parse_gotoline(['a', '123', 'b']) 
    assert_equal [['a', '123', 'b'], 55], Milkode::Util::parse_gotoline(['a', '123', 'b', '55'])
    assert_equal [['a', 'b'], 1], Milkode::Util::parse_gotoline(['a', 'b'])
  end
  
  def teardown
    teardown_custom(true)
    #    teardown_custom(false)
  end
end


