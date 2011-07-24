# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'milkode/common/util'
require 'test/unit'
require 'file_test_utils'

class TestUtil < Test::Unit::TestCase
  include FileTestUtils

  def test_zip_extract
    CodeStock::Util::zip_extract('../data/abc.zip', '.')
    assert File.exist?('abc')
    assert File.exist?('abc/a.txt')
    assert File.exist?('abc/b.txt')
    assert File.exist?('abc/c.txt')
    
    CodeStock::Util::zip_extract('../data/nodir_abc.zip', '.')
    assert File.exist?('nodir_abc')
    assert File.exist?('nodir_abc/a.txt')
    assert File.exist?('nodir_abc/b.txt')
    assert File.exist?('nodir_abc/c.txt')
  end

  def test_root_entrylist
    assert_equal ['abc/'], CodeStock::Util::root_entrylist('../data/abc.zip')
    assert_equal ['a.txt', 'b.txt', 'c.txt'], CodeStock::Util::root_entrylist('../data/nodir_abc.zip')
  end
  
  def teardown
    teardown_custom(true)
    #    teardown_custom(false)
  end
end


