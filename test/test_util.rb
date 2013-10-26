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

  # Remove because fail test on single test
  # def test_root_entrylist
  #   assert_equal ['abc/'], Milkode::Util::root_entrylist('../data/abc.zip')
  #   assert_equal ['a.txt', 'b.txt', 'c.txt'], Milkode::Util::root_entrylist('../data/nodir_abc.zip')
  # end

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

  def test_ignore_case?
    assert_equal true,  Milkode::Util::ignore_case?(['a', 'b'], false)
    assert_equal false, Milkode::Util::ignore_case?(['a', 'b'], true)
    assert_equal false, Milkode::Util::ignore_case?(['a', 'B'], false)
    assert_equal false, Milkode::Util::ignore_case?(['A', 'b'], true)
  end

  def test_parse_gotoline
    assert_equal [[['a', 'b'], 123]],       Milkode::Util::parse_gotoline(['a', '123', 'b']) 
    assert_equal [[['a', '123', 'b'], 55]], Milkode::Util::parse_gotoline(['a', '123', 'b', '55'])
    assert_equal [[['a', 'b'], 1]], Milkode::Util::parse_gotoline(['a', 'b'])
    assert_equal [[['a'], 55]],    Milkode::Util::parse_gotoline(['a:55'])
    assert_equal [[['lib/aaa.c'], 8], [['test/bbb.rb'], 9]],    Milkode::Util::parse_gotoline(['lib/aaa.c:8', 'test/bbb.rb:9'])
    assert_equal [[['c:/tmp/ccc.txt'], 99]],    Milkode::Util::parse_gotoline(['c:/tmp/ccc.txt:99'])
    assert_equal [[['/milkode/hoge.rb'], 99]],    Milkode::Util::parse_gotoline(['/milkode/hoge.rb:99'])
  end
  
  def test_gotoline_multi?
    assert_equal true,  Milkode::Util::gotoline_multi?("test:1".split)
    assert_equal true,  Milkode::Util::gotoline_multi?("test.rb:5 lib.c:10".split)
    assert_equal false,  Milkode::Util::gotoline_multi?("a 123 b".split)
    assert_equal false,  Milkode::Util::gotoline_multi?("c:/user 5".split)
  end

  def test_git_url?
    assert_equal false, Milkode::Util::git_url?('http:://ongaeshi.me')
    assert_equal  true, Milkode::Util::git_url?('git://github.com/ongaeshi/milkode.git')
    assert_equal  true, Milkode::Util::git_url?('git@github.com:ongaeshi/milkode.git')
    assert_equal  true, Milkode::Util::git_url?('ssh:foo@bar/baz.git')
  end

  def test_svn_url?
    assert_equal  true, Milkode::Util::svn_url?('svn://ongaeshi.me/svn/trunk/')
    assert_equal  true, Milkode::Util::svn_url?('svn+ssh://ongaeshi.me/svn/trunk/')
    assert_equal false, Milkode::Util::svn_url?('svna://ongaeshi.me/svn/trunk/')
    assert_equal false, Milkode::Util::svn_url?('http:://ongaeshi.me')
    assert_equal false, Milkode::Util::svn_url?('git://github.com/ongaeshi/milkode.git')
    assert_equal false, Milkode::Util::svn_url?('git@github.com:ongaeshi/milkode.git')
    assert_equal false, Milkode::Util::svn_url?('ssh:foo@bar/baz.git')
  end

  def test_divide_shortpath
    package, restpath = Milkode::Util::divide_shortpath('package/to/a.txt')
    assert_equal 'package', package
    assert_equal 'to/a.txt', restpath

    package, restpath = Milkode::Util::divide_shortpath('/package/to/a.txt')
    assert_equal 'package', package
    assert_equal 'to/a.txt', restpath
  end
      
  def test_highlight_keywords
    assert_equal "stringstr", Milkode::Util::highlight_keywords("stringstr", [], 'attr')
    assert_equal "<span class='attr'>str</span>ing", Milkode::Util::highlight_keywords("string", ["str"], 'attr')
    assert_equal "<span class='attr'>str</span>ing<span class='attr'>str</span>", Milkode::Util::highlight_keywords("stringstr", ["str"], 'attr')
    assert_equal "<span class='attr'>stri</span>ng<span class='attr'>str</span>", Milkode::Util::highlight_keywords("stringstr", ["str", "i", "s"], 'attr')
    assert_equal "abc<span class='attr'>d</span>", Milkode::Util::highlight_keywords("abcd", ["d"], 'attr')
    assert_equal "<span class='attr'>日本</span>語a<span class='attr'>bc</span>dで<span class='attr'>す</span>", Milkode::Util::highlight_keywords("日本語abcdです", ["bc", "日本", "す"], 'attr')
    assert_equal "<span><span class='attr'>span</span></span>", Milkode::Util::highlight_keywords("<span>span</span>", ["span"], 'attr')
  end

 def test_github_repo
    assert_equal 'ongaeshi/firelink', Milkode::Util::github_repo('git@github.com:ongaeshi/firelink.git')
    assert_equal 'ongaeshi/milkode' , Milkode::Util::github_repo('git@github.com:ongaeshi/milkode.git')
    assert_equal 'ongaeshi/milkode' , Milkode::Util::github_repo('git://github.com/ongaeshi/milkode.git')
    assert_equal 'ongaeshi/milkode' , Milkode::Util::github_repo('https://github.com/ongaeshi/milkode.git')
    assert_equal 'ongaeshi/milkode' , Milkode::Util::github_repo('http://github.com/ongaeshi/milkode.git')
    assert_equal nil                , Milkode::Util::github_repo('https://ongaeshi.me/ongaeshi/milkode.git')
  end

 def teardown
    teardown_custom(true)
    #    teardown_custom(false)
  end
end


