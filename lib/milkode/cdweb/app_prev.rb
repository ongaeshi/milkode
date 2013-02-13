# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/02/14

require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'

$LOAD_PATH.unshift '../..'
require 'milkode/cdweb/lib/database'
require 'milkode/cdweb/lib/command'
require 'milkode/cdweb/lib/mkurl'
require 'milkode/cdweb/lib/web_setting'
require 'milkode/cdweb/lib/package_list'
require 'milkode/common/util'

set :haml, :format => :html5

get '/' do
  @setting = WebSetting.new
  @version = "0.9.7"
  @package_num = Database.instance.yaml_package_num
  @file_num = Database.instance.totalRecords
  @package_list = PackageList.new(Database.instance.grndb)
  haml :index, :layout => false
end

def package_path(path)
  path.split('/')[0,3].join('/')
end

post '/search*' do
  path = unescape(params[:pathname])

  if params[:clear]
    redirect Mkurl.new("#{path}", params).inherit_shead
  else
    case params[:shead]
    when 'all'
      path = "/home"
    when 'package'
      path = package_path(path)
    when 'directory'
      # do nothing
    else
      path = package_path(path)
    end

    query = Query.new(params[:query])
    # gotolineモードで1つだけ渡された時は直接ジャンプ
    if query.keywords.size == 1 && Milkode::Util::gotoline_keyword?(query.keywords[0])
      gotoline = Milkode::Util::parse_gotoline(query.keywords)[0]
      path2 = File.join('/home', gotoline[0][0])
      redirect Mkurl.new(path2, params).inherit_query_shead + "#n#{gotoline[1]}"
    else
      redirect Mkurl.new("#{path}", params).inherit_query_shead
    end
  end
end

post '/command' do
  case params[:kind]
  when 'update'
    before = Time.now
    if (params[:name] == '')
      result = Database.instance.update_all
      update_result_str(result, before)
    else
      result = Database.instance.update(params[:name])
      update_result_str(result, before)
    end
  end
end

get '/home*' do |path|
  before = Time.now
  path = path.sub(/^\//, "")
  record = Database.instance.record(path)

  if path.empty?
    if (params[:query] and !params[:query].empty?)
      search(path, params, before)
    else
      packages(params, before)
    end
  elsif (record)
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
  @setting = WebSetting.new
  haml :help
end
