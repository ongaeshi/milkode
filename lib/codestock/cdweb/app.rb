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
require 'codestock/cdweb/lib/database'
require 'codestock/cdweb/lib/command'

set :haml, :format => :html5

helpers do
  # -- escape functions --
  alias h escape_html
  alias escape_url escape

  def escape_path(src)
    escape_url(src).gsub("%2F", '/')
  end
  
  # -- utility -- 
  def link(query)
    "<a href='#{'/home?keyword=' + escape_url(query)}'>#{query}</a>"
  end

  def create_form(query, package_name)
#     all_op = package_op = directory_op = ""

#     case search_op
#     when "all"
#       all_op = "checked"
#     when "package"
#       package_op = "checked"
#     else
#       directory_op = "checked"
#     end
    
    <<EOF
  <form action='' method='post'>
    <p>
      <input name='query' size='60' type='text' value="#{query}" />
      <input type='submit' value='検索'><br></input>
      <input name='search_op' type='radio' value='all'/>
      <label>全体を検索</label>
      <input name='search_op' type='radio' value='package'/>
      <label> #{package_name} 以下</label>
      <input name='search_op' type='radio' value='directory' checked />
      <label>このディレクトリ以下</label>
    </p>
  </form>
EOF
  end
end

get '/' do
  @version = '0.1.2'
  @package_num = Database.instance.fileList('').size
  @file_num = Database.instance.fileNum
  haml :index
end

post '/home*' do |path|
  path = path.sub(/^\//, "")

  case params[:search_op]
  when 'all'
    path = ""
  when 'package'
    path = path.split('/')[0]
  end

  url = "/home#{path}?keyword=#{escape_url(params[:query])}"
  url += "&search_op?=#{params[:search_op]}" if params[:search_op]

  redirect url
end

get '/home*' do |path|
  before = Time.now
  path = path.sub(/^\//, "")
  record = Database.instance.record(path)

  if (record)
    view(record, before)
  else
    unless (params[:keyword])
      filelist(path, before)
    else
      search(path, params, before)
    end
  end
end

get %r{/help} do
  haml :help
end
