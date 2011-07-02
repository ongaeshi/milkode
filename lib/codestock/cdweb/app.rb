# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/06/25

require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'

$LOAD_PATH.unshift '../..'

set :haml, :format => :html5

helpers do
  alias h escape_html
end

get '/' do
  # @todo @file_num = Database.instance.fileNum
  @version = '0.1.2'
  @file_num = 20001
  haml :index
end

get '/*.css' do |path|
  scss path.to_sym
end

get '/*.html' do |path|
  pass unless File.exist?(File.join(options.views, "#{path}.haml"))
  haml path.to_sym
end

get '/*' do |path|
  pass unless File.exist?(File.join(options.views, "#{path}.haml"))
  haml path.to_sym
end

# -- Sample app (delete OK) -- 

get '/hello*' do |path|
  num = path.to_i
  num = 1 if num == 0

  hello = 'Hello '
  hello = 'Hel ' if (num > 10000)
  hello = 'H ' if (num > 100000)
  return "The end." if (num > 1000000)
    
  str = "hello#{num} -> <a href=\"hello#{num*2}\">#{num*2}</a>"
  str += "<p>" + "#{hello}" * num + "</p>"
  str
end

get '/weekday' do
  wday = Time.new.wday
  r = []
  r << "en : #{['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][wday]}"
  r << "ja : #{['日曜日', '月曜日', '火曜日', '水曜日', '木曜日', '金曜日', '土曜日'][wday]}"
  r << "fr : #{['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'][wday]}"
  r.join("<br>")
end

# ユーザエージェントの表示
get '/user_agent' do
  request.user_agent
end
