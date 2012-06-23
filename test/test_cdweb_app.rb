# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/06/23

require 'milkode/cdweb/app.rb'
require 'test/unit'
require 'rack/test'

class TestCdwebApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # テスト用のデータベースを作成する必要がある

  # def test_default
  #   get '/'
  #   assert_equal 200, last_response.status
  # end

  # def test_home
  #   get '/home'
  #   assert_equal 200, last_response.status

  #   get '/home', :query => 'test'
  #   assert_equal 200, last_response.status
  # end

  # def test_help
  #   get '/help'
  #   assert_equal 200, last_response.status
  # end

  # def test_not_found
  #   get '/not_found'
  #   assert_equal 404, last_response.status
  # end

  # def test_view_empty_file
  #   get '/home/jruby-1.6.5.1/test/externals/ruby1.9/rdoc/empty.dat'
  #   # assert_equal 200, last_response.status
  #   assert_equal 500, last_response.status # 空ファイルも表示出来るようにする
  # end
end


