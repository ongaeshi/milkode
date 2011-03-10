# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/10/21

require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '../lib/grenweb/query')

class TestGrenWebQuery < Test::Unit::TestCase
  include Grenweb
  include Rack::Utils

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
    assert_equal q.escape_html, '&amp;p'

    q = create_query("int &p")
    assert_equal q.escape_html, 'int &amp;p'

    q = create_query('"def update"')
    assert_equal q.keywords, ['def update']
  end

  def create_query(query)
    Query.new(Rack::Request.new({"PATH_INFO"=>"/#{escape(query)}/"}))
  end
end
