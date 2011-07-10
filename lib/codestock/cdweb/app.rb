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
require 'codestock/cdweb/lib/coderay_wrapper'
require 'codestock/cdweb/lib/searcher'

set :haml, :format => :html5

helpers do
  # -- escape functions --
  alias h escape_html
  alias escape_url escape

  def escape_path(src)
    escape_url(src).gsub("%2F", '/')
  end
  
  # -- utility -- 
  def link(keyword)
    "<a href='#{'/::search' + '/' + escape_url(keyword)}'>#{keyword}</a>"
  end

  def topic_path(path)
    href = '/home'
    path.split('/').map {|v|
      href += '/' + v
      "<a href='#{escape_path(href)}'>#{v}</a>"
    }.join(' / ')
  end

  def view(record, before)
    @title = record.shortpath
    @path = topic_path(record.shortpath)
    @record_content = CodeRayWrapper.html_memfile(record.content, record.shortpath)
    @elapsed = Time.now - before
    haml :view
  end
end

get '/' do
  @version = '0.1.2'
  @package_num = Database.instance.fileList('').size
  @file_num = Database.instance.fileNum
  haml :index
end

post '/home*' do |path|
  redirect "/home#{path}?#{escape_url(params[:query])}"
end

get '/home*' do |path|
  before = Time.now
  path = path.sub(/^\//, "")
  record = Database.instance.record(path)

  if (record)
    view(record, before)
  else
    fileList = Database.instance.fileList(path)
    @title = (path == "") ? "Package List" : path
    @keyword = ""
    @filepath = topic_path(path)
    @total_records = fileList.size
    @record_content = fileList.map {|v| "<dt class='result-record'><a href='/home/#{escape_path(v[0])}'>#{File.basename v[0]}</a></dt>" }
    @package_name = (path == "") ? 'root' : path.split('/')[0]
    @elapsed = Time.now - before
    haml :filelist
  end
end

get %r{/::help} do
  haml :help
end

# -- obsolate --

post '/::search' do
  redirect "/::search/#{escape_url(params[:query])}"
end

get %r{/::search/(.*)} do |keyword|
  before = Time.now

  searcher = Searcher.new(keyword, params[:page].to_i)
  
  @keyword = searcher.keyword
  @total_records = searcher.total_records
  @range = searcher.page_range
  @elapsed = Time.now - before
  @record_content = searcher.html_contents  + searcher.html_pagination;
  haml :search
end

get %r{/::view/(.*)} do |path|
  before = Time.now
  record = Database.instance.record(path)
  view(record, before)
end

