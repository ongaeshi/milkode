# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/10/21

require 'test_helper'
require 'milkode/cdweb/lib/query'

module Milkode
  class TestQuery < Test::Unit::TestCase
    def test_query
      q = create_query("test fire beam")
      assert_equal q.keywords, ['test', 'fire', 'beam']
      assert_equal q.packages, []
      assert_equal q.fpaths, []
      assert_equal q.suffixs, []
      assert_equal q.escape_html, 'test fire beam'

      q = create_query("test fire beam f:testfile1")
      assert_equal q.keywords, ['test', 'fire', 'beam']
      assert_equal q.packages, []
      assert_equal q.fpaths, ['testfile1']
      assert_equal q.suffixs, []
      
      q = create_query("test fire beam f:testfile1 filepath:dir32")
      assert_equal q.keywords, ['test', 'fire', 'beam']
      assert_equal q.packages, []
      assert_equal q.fpaths, ['dir32', 'testfile1']
      assert_equal q.suffixs, []

      q = create_query("package:gren test fire beam f:testfile1 filepath:dir32 s:rb p:test suffix:pl")
      assert_equal q.keywords, ['test', 'fire', 'beam']
      assert_equal q.packages, ['gren', 'test']
      assert_equal q.fpaths, ['dir32', 'testfile1']
      assert_equal q.suffixs, ['pl', 'rb']

      q = create_query("&p")
      assert_equal "&p", q.query_string
      assert_equal q.escape_html, '&amp;p'

      q = create_query("int &p")
      assert_equal q.escape_html, 'int &amp;p'

      q = create_query('"def update"')
      assert_equal q.keywords, ['def update']
    end

    def test_conv_keywords_to_fpath
      q = create_query("array test s:rb")
      assert_equal q.conv_keywords_to_fpath.query_string, 'f:array f:test s:rb'

      q = create_query("hoge")
      assert_equal q.conv_keywords_to_fpath.query_string, 'f:hoge'

      q = create_query("hoge f:hoge")
      assert_equal q.conv_keywords_to_fpath.query_string, 'f:hoge f:hoge'
    end

    def test_fp
      q = create_query("key1 fp:pack fp:age")
      assert_equal q.keywords, ['key1']
      assert_equal q.packages, []
      assert_equal q.fpaths, []
      assert_equal q.suffixs, []
      assert_equal q.fpath_or_packages, ['pack', 'age']
    end

    def test_conv_keywords_to_fpath_or_packages
      q = create_query("array test s:rb")
      assert_equal q.conv_keywords_to_fpath_or_packages.query_string, 'fp:array fp:test s:rb'
    end

    def test_gotolines
      q = create_query("g:test.rb:11 a.rb")
      assert_equal q.gotolines, ['test.rb:11']
      assert_equal q.keywords , ['a.rb']
    end

    def test_wide_match_range
      assert_equal 1, create_query("").wide_match_range
      assert_equal 1, create_query("w:1").wide_match_range
      assert_equal 7, create_query("w:5 w:7").wide_match_range
      assert_equal 1, create_query("w:aaa").wide_match_range
    end

    private

    def create_query(query)
      Query.new(query)
    end
  end
end
