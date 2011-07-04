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

set :haml, :format => :html5

helpers do
  alias h escape_html

  def link(keyword)
    "<a href='#{'/::search' + '/' + h(keyword)}'>#{keyword}</a>"
  end
end

get '/' do
  @version = '0.1.2'
  @file_num = Database.instance.fileNum
  haml :index
end

post '/::search' do
  redirect "/::search/#{escape(params[:query])}"
end

get %r{/::search/(.*)} do |path|
  @keyword = path
  @total_records = 105
  @range = 0..10
  @elapsed = 0.551
  haml :search
end

get %r{/::view/(.*)} do |path|
  record, elapsed = Database.instance.record(path)
  @title = @path = record.shortpath
  @elapsed = elapsed
  @record_content = CodeRayWrapper.html_memfile(record.content, record.shortpath)
  haml :view
end

get %r{/::help} do
  haml :help
end

