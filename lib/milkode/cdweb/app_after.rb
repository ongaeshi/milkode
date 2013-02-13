# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/02/14

# /css のカスタマイズが出来ないため外した
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
    href = Mkurl.new('/home/' + path, params).inherit_query_shead
    flist = File.join("/home/#{path}", flistpath)

    package_name = ""
    modal_body = "全てのパッケージを更新しますか？"

    if (path != "")
      package_name = path.split('/')[0]
      modal_body = "#{package_name} を更新しますか？"
    end

    <<EOF
    #{headicon('go-home-5.png')} <a href="/home" class="headmenu">ホーム</a>
    #{headicon('document-new-4.png')} <a href="#{href}" class="headmenu" onclick="window.open(document.URL); return false;">タブを複製</a>
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

  def update_result_str(result, before)
    r = []
    r << "#{result.package_count} packages" if result.package_count > 1
    r << "#{result.file_count} records"
    r << "#{result.add_count} add"
    r << "#{result.update_count} update"
    "#{r.join(', ')} (#{Time.now - before} sec)"
  end

  # .search-summary に追加情報を表示したい時はこの関数をオーバーライド
  def search_summary_hook(path)
    ""
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
