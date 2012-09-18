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
require 'milkode/cdweb/lib/web_setting'
require 'milkode/cdweb/lib/package_list'
require 'milkode/common/util'

set :haml, :format => :html5

get '/' do
  @setting = WebSetting.new
  @version = "0.9.2"
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
    if (params[:name] == '')
      result = Database.instance.update_all
      update_result_str(result)
    else
      result = Database.instance.update(params[:name])
      update_result_str(result)
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

get '*' do
  @setting = WebSetting.new
  @path    = ''
  haml :error
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

  def create_select_shead(value)
    value ||= "package"

    data = [
            ['all'      , '全て'        ],
            ['package'  , 'パッケージ'  ],
            ['directory', 'ディレクトリ'],
           ]

    <<EOF
<select name="shead" id="shead">
#{data.map{|v| "<option value='#{v[0]}' #{v[0] == value ? 'selected' : ''}>#{v[1]}</option>"}}
</select>
EOF
  end

  def create_select_package(path)
    value = package_name(path)
    value = '---' if value == "root"
    data = ['---'] + Database.instance.packages(nil)

    <<EOF
<select name="package" id="package" onchange="select_package()">
#{data.map{|v| "<option value='#{v}' #{v == value ? 'selected' : ''}>#{v}</option>"}}
</select>
EOF
  end

  def create_select_package_home
    value = '---'
    data = ['---'] + Database.instance.packages(nil)

    <<EOF
<select name="package" id="package_home" onchange="select_package_home()">
#{data.map{|v| "<option value='#{v}' #{v == value ? 'selected' : ''}>#{v}</option>"}}
</select>
EOF
  end

  def create_checkbox(name, value, label)
    str = (value) ? 'checked' : ''
    "<label class='checkbox inline'><input type='checkbox' name='#{name}' value='on' #{str}/>#{label}</label>"
  end

  def create_headmenu(path, query, flistpath = '')
    href = Mkurl.new('/home/' + path, params).inherit_query_shead
    flist = File.join("/home/#{path}", flistpath)

    package_name = ""
    modal_body = "Update all package?"

    if (path != "")
      package_name = path.split('/')[0]
      modal_body = "Update #{package_name}?"
    end

    <<EOF
    #{headicon('go-home-5.png')} <a href="/home" class="headmenu">ホーム</a>
    #{headicon('document-new-4.png')} <a href="#{href}" class="headmenu" onclick="window.open('#{href}'); return false;">新しい検索</a>
    #{headicon('directory.png')} <a href="#{flist}" class="headmenu">ディレクトリ</a> 
    #{headicon('view-refresh-4.png')} <a href="#updateModal" class="headmenu" data-toggle="modal">パッケージを更新</a>
    #{headicon('help.png')} <a href="/help" class="headmenu">ヘルプ</a>

    <div id="updateModal" class="modal hide fade">
      <div class="modal-header">
        <a href="#" class="close" data-dismiss="modal">&times;</a>
        <h3>パッケージを更新</h3>
      </div>
      <div class="modal-body">
        <h4>#{modal_body}</h4>
      </div>
      <div class="modal-footer">
        <a href="#" class="btn" data-dismiss="modal">Cancel</a>
        <a href="#" class="btn btn-primary" onclick="update_package('#{package_name}')">OK</a>
      </div>
    </div>
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

  HASH = {
    '.h'   => ['.c', '.cpp', '.m', '.mm'],
    '.c'   => ['.h'],
    '.hpp' => ['.cpp'],
    '.cpp' => ['.hpp', '.h'],
    '.m'   => ['.h'],
    '.mm'  => ['.h'],
  }

  def additional_info(path, parms)
    suffix = File.extname path
    cadet = HASH[suffix]

    if (cadet)
      result = cadet.find do |v|
        Database.instance.record(path.gsub(/#{suffix}\Z/, v))
      end

      if (result)
        path2 = path.gsub(/#{suffix}\Z/, result)
        " (<a href='#{Mkurl.new(File.join('/home', path2), params).inherit_query_shead}'>#{result}</a>) "
      else
        ''
      end
    else
      ''
    end
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

  def update_result_str(result)
    r = []
    r << "#{result.package_count} packages" if result.package_count > 1
    r << "#{result.file_count} records"
    r << "#{result.add_count} add"
    r << "#{result.update_count} update"
    "result : #{r.join(', ')}"
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
