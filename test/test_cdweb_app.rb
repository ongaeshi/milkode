# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/06/23

require 'milkode/cdweb/app'
require 'milkode/cdweb/lib/database'
require 'test_helper'
require 'test/unit'
require 'rack/test'
require 'milkode_test_work'

class TestCdwebApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    @work = MilkodeTestWork.new({:default_db => true})
    @work.add_package "db1", @work.expand_path("../data/a_project")

    Database.setup(Dbdir.default_dir)
    Database.instance.open_force
  end

  def teardown
    @work.teardown
  end

  def app
    Sinatra::Application
  end

  # def test_main
  #   t_default
  #   t_home
  #   t_help
  #   t_not_found
  #   t_view_empty_file
  #   t_view_with_query
  #   t_view_gotoline
  #   t_view_simple
  #   t_search_contents
  #   t_search_gotoline
  #   t_search_fuzzy_gotoline
  # end

  private
  
  def t_default
    get '/'
    assert_equal 200, last_response.status
  end

  def t_home
    get '/home'
    assert_equal 200, last_response.status

    get '/home', :query => 'test'
    assert_equal 200, last_response.status
  end

  def t_help
    get '/help'
    assert_equal 200, last_response.status
  end

  def t_not_found
    get '/not_found'
    assert_equal 404, last_response.status
  end

  def t_view_empty_file
    get '/home/a_project/empty.txt'
    assert_equal 200, last_response.status # 空ファイルも表示出来るようにする
  end

  def t_view_with_query
    get '/home/a_project/cdstk.rb?query=def'
    assert_equal 200, last_response.status
  end

  def t_view_gotoline
    get '/home/a_project/cdstk.rb?query=%2Fa_project%2Fcdstk.rb%3A9'
    assert_equal 200, last_response.status
  end

  def t_view_simple
    get '/home/a_project/cdstk.rb'
    assert_equal 200, last_response.status
  end

  def t_search_contents
    get '/home/?query=def'
    assert_equal 200, last_response.status
  end

  def t_search_gotoline
    get '/home/?query=%2Fa_project%2Fcdstk.rb%3A1&shead=package#n1'
    assert_equal 200, last_response.status
  end

  def t_search_fuzzy_gotoline
    get '/home/?query=g%3Aa_project+1&shead=package'
    assert_equal 200, last_response.status
  end
end


