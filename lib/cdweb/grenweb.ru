# -*- mode: ruby; coding: utf-8 -*-
#
# @file   
# @brief  gren web検索
# @author ongaeshi
# @date   2010/10/13

require 'rubygems'
require 'rack'
require File.join(File.dirname(__FILE__), 'home')
require File.join(File.dirname(__FILE__), 'searcher')
require File.join(File.dirname(__FILE__), 'viewer')
require File.join(File.dirname(__FILE__), 'help')

use Rack::CommonLogger          
use Rack::Runtime
use Rack::Static, :urls => ["/css", "/images"], :root => "public"
use Rack::ContentLength

map '/' do
  run Grenweb::Home.new
end

map '/::search' do
  run Grenweb::Searcher.new
end

map '/::view' do
  run Grenweb::Viewer.new
end

map '/::help' do
  run Grenweb::Help.new
end

