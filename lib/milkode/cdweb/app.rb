# -*- coding: utf-8 -*-
require 'rubygems'
require 'sinatra'
require 'sass'
require 'haml'
require 'i18n'

if ENV['MILKODE_SINATRA_RELOADER']
  require 'sinatra/reloader'
  also_reload '../../**/*.rb'
end

$LOAD_PATH.unshift '../..'
require 'milkode/common/util'
require 'milkode/cdweb/lib/database'
require 'milkode/cdweb/lib/command'
require 'milkode/cdweb/lib/mkurl'
require 'milkode/cdweb/lib/web_setting'
require 'milkode/cdweb/lib/package_list'
require 'milkode/cdweb/lib/info_home'
require 'milkode/cdweb/lib/info_package'
require 'sinatra/url_for'

I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]

set :haml, :format => :html5
enable :sessions

get '/js/:filename' do
  content_type :js
  erb(File.read(File.join(settings.views, params[:filename])))
end

get '/css/milkode.css' do
  content_type :css

  contents = File.read(File.join(settings.views, 'milkode.scss'))
  contents = erb(contents)
  engine   = Sass::Engine.new(contents, :syntax => :scss)
  engine.render
end

get '/' do
  if Database.validate?
    @setting = WebSetting.new
    @version = "1.4.0"

    @package_num = Database.instance.yaml_package_num
    @file_num = Database.instance.totalRecords
    @package_list = PackageList.new(Database.instance.grndb, url_for(''))
    haml :index, :layout => false
  else
    <<EOF
<h1>Setup Error!</h1>
Database Directory: #{Database.dbdir}<br>
EOF
  end
end

def package_path(homeurl, path)
  homeurl + path.sub(homeurl, "").split('/')[0,2].join('/')
end

post '/search*' do
  path = unescape(params[:pathname])

  if params[:clear]
    redirect Mkurl.new("#{path}", params).inherit_shead
  else
    homeurl = url_for "/home"
    
    case params[:shead]
    when 'all'
      path = homeurl
    when 'package'
      path = package_path(homeurl, path)
    when 'directory'
      # do nothing
    else
      path = package_path(homeurl, path)
    end

    query = Query.new(params[:query])
    # gotolineモードで1つだけ渡された時は直接ジャンプ
    if query.keywords.size == 1 && Milkode::Util::gotoline_keyword?(query.keywords[0])
      gotoline = Milkode::Util::parse_gotoline(query.keywords)[0]
      path2 = File.join(url_for('/home'), gotoline[0][0])
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
  when 'favorite'
    Database.instance.set_fav(params[:name], params[:favorited] == 'true')
    @package_list = PackageList.new(Database.instance.grndb, url_for(''))
    t(:favorite) + ": " + @package_list.favorite_list({})
  end
end

get '/home*' do |path|
  before = Time.now
  path = path.sub(/^\//, "")
  record = Database.instance.record(path)
  @package_list = PackageList.new(Database.instance.grndb, url_for(''))
  suburl = url_for('')
  update_locale

  if path.empty?
    if (params[:query] and !params[:query].empty?)
      search(path, params, before, suburl, @locale)
    else
      packages(params, before, suburl, @locale)
    end
  elsif (record)
    view(record, params, before)
  else
    if (params[:query] and !params[:query].empty?)
      search(path, params, before, suburl, @locale)
    else
      filelist(path, params, before, suburl)
    end
  end
end

get %r{/help} do
  @setting = WebSetting.new
  @path                = ""
  haml :help
end

get '/info' do
  obj = InfoHome.new(url_for '')

  @setting             = WebSetting.new
  @path                = ""
  @summary_content     = obj.summary_content
  @record_content      = obj.record_content
  
  haml :info_home
end

get '/info/:package' do
  before = Time.now

  name = params[:package]
  obj = InfoPackage.new(name, url_for(''))
    
  @setting         = WebSetting.new
  @path            = name
  @summary_content = obj.summary_content
  @plang_content   = obj.plang_content

  @elapsed = Time.now - before

  haml :info_package
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
  def link(query, text = nil)
    if text.nil?
      "<a href='#{'/home?query=' + escape_url(query)}'>#{query}</a>"
    else
      "<a href='#{'/home?query=' + escape_url(query)}'>#{text}</a>"
    end
  end

  def create_select_shead(value)
    value ||= "package"

    data = [
            ['all'      , t(:all)      ],
            ['package'  , t(:package)  ],
            ['directory', t(:directory)],
           ]

    <<EOF
<select name="shead" id="shead">
#{data.map{|v| "<option value='#{v[0]}' #{v[0] == value ? 'selected' : ''}>#{v[1]}</option>"}.join}
</select>
EOF
  end

  def create_select_package(path)
    value = package_name(path)
    value = '---' if value == "root"
    data = ['---'] + Database.instance.packages(nil)

    <<EOF
<select name="package" id="package" onchange="select_package()">
#{data.map{|v| "<option value='#{v}' #{v == value ? 'selected' : ''}>#{v}</option>"}.join}
</select>
EOF
  end

  def create_select_package_home
    value = '---'
    data = ['---'] + Database.instance.packages(nil)

    <<EOF
<select name="package" id="package_home" onchange="select_package_home()">
#{data.map{|v| "<option value='#{v}' #{v == value ? 'selected' : ''}>#{v}</option>"}.join}
</select>
EOF
  end

  def create_checkbox(name, value, label)
    str = (value) ? 'checked' : ''
    "<label class='checkbox inline'><input type='checkbox' name='#{name}' value='on' #{str}/>#{label}</label>"
  end

  def create_headmenu(path, query, flistpath = '')
    suburl = url_for ""

    href = Mkurl.new("#{suburl}/home/#{path}", params).inherit_query_shead
    flist = File.join("#{suburl}/home/#{path}", flistpath)

    package_name = ""
    modal_body = t(:update_all)

    if (path != "")
      package_name = path.split('/')[0]
      update_locale
      modal_body = I18n.t(:update_package, {package_name: package_name, locale: @locale})
    end

    info_path = "#{suburl}/info"
    info_path = File.join(info_path, package_name) if package_name != ""

    <<EOF
    #{headicon('go-home-5.png', suburl)}<a href="#{suburl}/home" class="headmenu">#{t(:home)}</a>&nbsp;
    #{headicon('directory.png', suburl)}<a href="#{flist}" class="headmenu">#{t(:directory)}</a>
    #{headicon('view-refresh-4.png', suburl)}<a href="#updateModal" class="headmenu" data-toggle="modal">#{t(:update_packages)}</a>&nbsp;
    #{headicon('info.png', suburl)}<a href="#{info_path}" class="headmenu">#{t(:stats)}</a>&nbsp;
    #{headicon('help.png', suburl)}<a href="#{suburl}/help" class="headmenu">#{t(:help)}</a>

    <div id="updateModal" class="modal hide fade">
      <div class="modal-header">
        <a href="#" class="close" data-dismiss="modal">&times;</a>
        <h3>#{t(:update_packages)}</h3>
      </div>
      <div class="modal-body">
        <h4>#{modal_body}</h4>
      </div>
      <div class="modal-footer">
        <a href="#" id="updateCancel" class="btn" data-dismiss="modal">Cancel</a>
        <a href="#" id="updateOk" class="btn btn-primary" data-loading-text="Updating..." milkode-package-name="#{package_name}">OK</a>
      </div>
    </div>

    <div id="lineno-modal" class="modal hide">
      <div class="modal-header">
        <a href="#" class="close" data-dismiss="modal">&times;</a>
        <h3 id="lineno-path"></h3>
      </div>
      <div class="modal-body">
        <table class="CodeRay"><tr>
          <td class="code"><pre id="lineno-body">
          </pre></td>
        </tr></table>
    </div>
      <div class="modal-footer">
        <span id="lineno-copyall"></span>
        <a href="#" id="lineno-ok" class="btn" data-dismiss="modal">OK</a>
      </div>
    </div>
EOF
  end

  def create_favorite_list(package_list)
    <<EOF
      <div class="favorite_list">
        #{t(:favorite)}:
        #{package_list.favorite_list(params)}
      </div>
    </div>
EOF
  end

  def headicon(name, suburl)
    "<img alt='' style='vertical-align:center; border: 0px; margin: 0px;' src='#{suburl}/images/#{name}'>"
  end

  def topic_path(path, params)
    href = ''
    path = File.join('home', path)

    path.split('/').map_with_index {|v, index|
      href += '/' + v
      "<a id='topic_#{index}' href='#{url_for Mkurl.new(href, params).inherit_query_shead}' onclick='topic_path(\"topic_#{index}\");'>#{v}</a>"
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
        " (<a href='#{url_for Mkurl.new(File.join('/home', path2), params).inherit_query_shead}'>#{result}</a>) "
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

  def update_result_str(result, before)
    r = []
    r << "#{result.package_count} packages" if result.package_count > 1
    r << "#{result.file_count} records"
    r << "#{result.add_count} add"
    r << "#{result.update_count} update"
    "#{r.join(', ')} (#{Time.now - before} sec)"
  end

  def favstar(path)
    pname   = package_name(path)

    if pname != "root"
      classes = Database.instance.fav?(pname) ? "star favorited" : "star"
      "<a href=\"javascript:\" class=\"#{classes}\" milkode-package-name=\"#{pname}\">Favorite Me</a>"
    else
      ""
    end
  end

  def goto_github_project(path)
    return "" if (path == "")

    paths = path.split('/')
    package = Database.instance.yaml_package(paths[0])
    return "" unless package.options[:github]
    
    image_href = 'https://raw.github.com/github/media/master/octocats/blacktocat-16.png'
    url = "https://github.com/#{package.options[:github]}"

    if (paths.size == 1)
      "<a href='#{url}' target=\"_blank\"><img src='#{image_href}'></img></a>"
    else
      "<a href='#{url}/tree/master/#{paths[1..-1].join('/')}' target=\"_blank\"><img src='#{image_href}'></img></a>"
    end
  end

  # .search-summary に追加情報を表示したい時はこの関数をオーバーライド
  def search_summary_hook(path)
    goto_github_project(path)
  end

  ## for I18N
  def ua_locale
    # Pulls the browser's language
    @env["HTTP_ACCEPT_LANGUAGE"][0,2]
  end

  def update_locale
    unless @locale
      begin
        # Support session
        @locale = params[:locale] || session[:locale] || ua_locale || 'en'
        session[:locale] = @locale
      rescue NameError          # 'session' variable can't find during testing
        @locale = 'en'
      end
        
      # Reload with sinatra-reloader
      I18n.reload! if ENV['MILKODE_SINATRA_RELOADER']
    end
  end

  def t(*args)
    update_locale
    I18n.t(*args, locale: @locale)
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
