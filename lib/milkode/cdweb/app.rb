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
  @version = "0.2.2"
  @package_num = Database.instance.fileList('').size
  @file_num = Database.instance.fileNum
  haml :index
end

post '/search*' do
  path = unescape(params[:pathname])
  
  case params[:shead]
  when 'all'
    path = "/home"
  when 'package'
    path = path.split('/')[0,3].join('/')
  end

  redirect Mkurl.new("#{path}", params).inherit_query_shead
end

get '/home*' do |path|
  before = Time.now
  path = path.sub(/^\//, "")
  record = Database.instance.record(path)

  if (record)
    view(record, params, before)
  else
    if (params[:query] and !params[:query].empty?)
      search(path, params, before)
    else
      filelist(path, params, before)
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
  <script type="text/javascript">
  function set_pathname() {
    document.searchform.pathname.value = location.pathname;
  }
  </script>
  <form name="searchform" action='/search' method='post'>
    <p>
      <input name='query' size='60' type='text' value='#{query}' />
      <input type='submit' value='検索' onclick='set_pathname()'><br></input>
      #{create_radio('all', shead)}
      <label>全体を検索</label>
      #{create_radio('package', shead)}
      <label> #{package_name(path)} 以下</label>
      #{create_radio('directory', shead)}
      <label> #{current_name(path)} 以下</label>
      <input name='pathname' type='hidden' value=''></input>
    </p>
  </form>
EOF
  end

  def create_radio(value, shead)
    str = (value == shead) ? 'checked' : ''
    "<input name='shead' type='radio' value='#{value}' #{str}/>"
  end

  def create_headmenu(path, query, flistpath = '')
    href = Mkurl.new('/home/' + path, params).inherit_query_shead
    flist = File.join("/home/#{path}", flistpath)
    <<EOF
    #{headicon('go-home-5.png')} <a href="/home" class="headmenu">全てのパッケージ</a>
    #{headicon('document-new-4.png')} <a href="#{href}" class="headmenu" onclick="window.open('#{href}'); return false;">新しい検索</a>
    #{headicon('directory.png')} <a href="#{flist}" class="headmenu">ファイル一覧</a> 
EOF
  end

  def headicon(name)
    "<img alt='' style='vertical-align:center; border: 0px; margin: 0px;' src='/images/#{name}'>"
  end

  def topic_path(path, params)
    href = ''
    path = File.join('home', path)

    path.split('/').map_with_index {|v, index|
      href += '/' + v
      "<a id='topic_#{index}' href='#{Mkurl.new(href, params).inherit_query_shead}' onclick='topic_path(\"topic_#{index}\");'>#{v}</a>"
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

class Array
  def map_with_index!
    each_with_index do |e, idx| self[idx] = yield(e, idx); end
  end

  def map_with_index(&block)
    dup.map_with_index!(&block)
  end
end
