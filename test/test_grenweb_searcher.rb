# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/10/21

require File.join(File.dirname(__FILE__), "test_helper.rb")
require File.join(File.dirname(__FILE__), "../lib/grenweb/searcher.rb")
require 'rack/mock'

class TestGrenwebSearcher < Test::Unit::TestCase
  def setup
    @app = Grenweb::Searcher.new
    @mr  = Rack::MockRequest.new(@app)
  end

  def test_get
    res = nil
    assert_nothing_raised('なんか失敗した') { res = @mr.get('/', :lint => true) }
    assert_not_nil res, 'レスポンス来てない'
    assert_equal 200, res.status, 'ステータスコードが変'
    assert_equal 'text/html; charset=UTF-8', res['Content-Type'], 'Content-Typeが変'
    #puts res.body
  end

  def test_post
    res = nil
    assert_nothing_raised('なんか失敗した') { res = @mr.post('/', :lint => true) }
    assert_not_nil res, 'レスポンス来てない'
    assert_equal 302, res.status, 'ステータスコードが変'
    assert_equal 'text/html; charset=UTF-8', res['Content-Type'], 'Content-Typeが変'
    #puts res.body
  end
end
