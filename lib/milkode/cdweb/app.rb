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
require 'milkode/cdweb/lib/database'
require 'milkode/cdweb/lib/command'
require 'milkode/cdweb/lib/mkurl'

set :haml, :format => :html5

get '/' do
  @version = "0.2.1"
  @package_num = Database.instance.fileList('').size
  @file_num = Database.instance.fileNum
  haml :index
end

post '/home*' do |path|
  path = path.sub(/^\//, "")

  case params[:shead]
  when 'all'
    path = ""
  when 'package'
    path = path.split('/')[0]
  end

  redirect Mkurl.new("home/#{path}", params).inherit_query_shead
end

get '/home*' do |path|
  before = Time.now
  path = path.sub(/^\//, "")
  record = Database.instance.record(path)

  if (record)
    view(record, params, before)
  else
    unless (params[:query])
      filelist(path, params, before)
    else
      search(path, params, before)
    end
  end
end

get %r{/help} do
  haml :help
end

# -- helper function --

helpers do
  # -- escape functions --
  alias h escape_html
  alias escape_url escape

  def escape_path(src)
    escape_url(src).gsub("%2F", '/')
  end
  
  # -- utility -- 
  def link(query)
    "<a href='#{'/home?query=' + escape_url(query)}'>#{query}</a>"
  end

  def create_form(path, query, shead)
    shead = shead || 'directory'
    
    # こっちにすると'検索'ボタンを押した時に新しくウィンドウが開く
    # <form action='' target='_blank' method='post'>
    <<EOF
  <form action='' method='post'>
    <p>
      <input name='query' size='60' type='text' value='#{query}' />
      <input type='submit' value='検索'><br></input>
      #{create_radio('all', shead)}
      <label>全体を検索</label>
      #{create_radio('package', shead)}
      <label> #{package_name(path)} 以下</label>
      #{create_radio('directory', shead)}
      <label> #{current_name(path)} 以下</label>
    </p>
  </form>
EOF
  end

  def create_radio(value, shead)
    str = (value == shead) ? 'checked' : ''
    "<input name='shead' type='radio' value='#{value}' #{str}/>"
  end

  def create_headmenu(path, query)
    # href = "#{request.path_info}?'#{request.query_string}"
    # href = '/home/rack-1.3.0/lib/rack/handler/cgi.rb?shead=directory'
    href = Mkurl.new('/home/' + path, params).inherit_query_shead
    <<EOF
    <a href="/home" class="headmenu">全てのパッケージ</a>
    <a href="#{href}" class="headmenu" onclick="window.open('#{href}'); return false;">新しい検索</a>
EOF
  end

  def topic_path(path, params)
    href = '/home'
    path.split('/').map {|v|
      href += '/' + v
      "<a href='#{Mkurl.new(href, params).inherit_shead}'>#{v}</a>"
    }.join('/')
  end

  def package_name(path)
    (path == "") ? 'root' : path.split('/')[0]
  end

  def current_name(path)
    (path == "") ? 'root' : File.basename(path)
  end

  def path_title(path)
    (path == "") ? "root" : path
  end

  def filelist_title(path)
    (path == "") ? "Package List" : path
  end
end

