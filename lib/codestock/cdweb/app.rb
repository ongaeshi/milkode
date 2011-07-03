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
require 'codestock/cdweb/database'

set :haml, :format => :html5

helpers do
  alias h escape_html

  def link(keyword)
    "<a href='#{'::search' + '/' + Rack::Utils::escape_html(keyword)}'>#{keyword}</a>"
  end
end

get '/' do
  # @todo @file_num = Database.instance.fileNum
  @version = '0.1.2'
  @file_num = 20001
  haml :index
end

# post '/::search' do
# end

# get '/::search' do
#   haml :search
# end

get %r{/::view/(.*)} do |path|
  record, elapsed = Database.instance.record(path)
  @title = @path = record.shortpath
  @elapsed = elapsed
  @record_content = '<pre>' + h(record.content) + '</pre>'
  haml :view
end

get %r{/::help} do
  haml :help
end

