# -*- mode: ruby; coding: utf-8 -*-
#
# @file   
# @brief  gren web検索
# @author ongaeshi
# @date   2010/10/13

require 'rubygems'
require 'rack'
require 'cdweb/home'
require 'cdweb/searcher'
require 'cdweb/viewer'
require 'cdweb/help'

use Rack::CommonLogger          
use Rack::Runtime
use Rack::Static, :urls => ["/css", "/images"], :root => "public"
use Rack::ContentLength

map '/' do
  run CodeStock::Home.new
end

map '/::search' do
  run CodeStock::Searcher.new
end

map '/::view' do
  run CodeStock::Viewer.new
end

map '/::help' do
  run CodeStock::Help.new
end

