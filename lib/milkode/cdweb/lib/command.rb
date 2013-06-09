# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/11

require 'milkode/cdweb/lib/database'
require 'milkode/cdweb/lib/coderay_wrapper'
require 'milkode/cdweb/lib/search_contents'
require 'milkode/cdweb/lib/search_files'
require 'milkode/cdweb/lib/search_gotoline'
require 'milkode/cdweb/lib/search_fuzzy_gotoline'
require 'milkode/cdweb/lib/mkurl'
require 'milkode/common/util'

module Milkode
  def view(record, params, before)
    @setting = WebSetting.new
    @title = record.shortpath
    @path = record.shortpath
    is_sensitive = params[:sensitive] == 'on'

    q = params[:query] && Query.new(params[:query]) 

    if (Util::larger_than_oneline(record.content) and q and !q.keywords.empty?)
      if Util::gotoline_keyword? q.keywords[0]
        gotolines = Util::parse_gotoline(q.keywords)
        match_lines = []
        gotolines.each do |v|
          if v[0][0][1..-1] == record.shortpath
              match_lines << Grep::MatchLineResult.new(v[1] - 1, nil)
          end
        end
        @record_content = CodeRayWrapper.new(record.content, record.shortpath, match_lines).to_html
      else
        grep = Grep.new(record.content)
        match_lines = grep.match_lines_and(q.keywords, is_sensitive, q.wide_match_range)

        if match_lines.empty? && q.wide_match_range_empty?
          # 検索範囲を広げる
          match_lines = grep.match_lines_and(q.keywords, is_sensitive, 7)
        end
        
        @record_content = CodeRayWrapper.new(record.content, record.shortpath, match_lines).to_html
      end
    else
      @record_content = CodeRayWrapper.new(record.content, record.shortpath).to_html
    end
    
    Database.instance.touch_viewtime(@path)
    @elapsed = Time.now - before
    haml :view
  end

  def search(path, params, before, suburl)
    @setting = WebSetting.new
    @path = path
    query = Query.new(params[:query])
    @title = "'#{query.query_string}' in #{path_title(path)}"

    if (query.gotolines.size > 0)
      searcher = SearchFuzzyGotoLine.new(path, params, query)

      if searcher.directjump?
        redirect searcher.directjump_url
      end

    elsif (query.keywords.size > 0)
      if Util::gotoline_keyword?(query.keywords[0])
        searcher = SearchGotoLine.new(path, params, query)
      else
        searcher = SearchContents.new(path, params, query, suburl)

        if searcher.directjump?
          redirect searcher.directjump_url
        end
      end
    else
      searcher = SearchFiles.new(path, params, query, suburl)
    end
    
    @total_records = searcher.total_records
    @range = searcher.data_range
    @record_content = "<dl class='autopagerize_page_element'>#{searcher.html_contents}</dl>#{searcher.html_pagination}";
    @match_num = searcher.match_num
    @elapsed = Time.now - before
    haml :search
  end

  def filelist(path, params, before, suburl)
    @setting = WebSetting.new
    @title = filelist_title(path)
    @path = path
    fileList = Database.instance.fileList(path)
    @total_records = fileList.size
    @record_content = fileList.map do |v|
      "<dt class='result-file'>#{file_or_dirimg(v[1], suburl)}<a href='#{Mkurl.new(suburl + '/home/' + v[0], params).inherit_query_shead}'>#{File.basename v[0]}</a></dt>"
    end.join
    Database.instance.touch_viewtime(path)
    @elapsed = Time.now - before
    haml :filelist
  end

  def packages(params, before, suburl)
    @setting = WebSetting.new
    @title = "Package List"
    @path = ""
    packages = Database.instance.packages(params["sort"])
    @total_records = packages.size

    @sort_change_content =
      [
       sort_change_content(params["sort"], '名前'),
       '|',
       sort_change_content(params["sort"], '最近使った', 'viewtime'),
       '|',
       sort_change_content(params["sort"], '追加順'    , 'addtime'),
       '|',
       sort_change_content(params["sort"], '更新順'    , 'updatetime'),
       '|',
       sort_change_content(params["sort"], 'お気に入り', 'favtime'),
      ].join("\n")

    @record_content = packages.map do |v|
      "<dt class='result-file'>#{file_or_dirimg(false, suburl)}<a href='#{Mkurl.new(suburl + '/home/' + v, params).inherit_query_shead}'>#{File.basename v}</a></dt>"
    end.join
    @elapsed = Time.now - before
    haml :packages
  end

  private
  
  def file_or_dirimg(is_file, suburl)
    filename = (is_file) ? 'file.png' : 'directory.png'
    img_icon(filename, suburl)
  end

  def img_icon(filename, suburl)
    "<img alt='' style='vertical-align:bottom; border: 0; margin: 1px;' src='#{suburl}/images/#{filename}'>"
  end

  def sort_change_content(current_value, text, sort_kind = nil)
    if (current_value != sort_kind)
      if (sort_kind)
        "<a href='#{Mkurl.new('/home', params).inherit_query_shead_set_sort(sort_kind)}'>#{text}</a>"
      else
        "<a href='#{Mkurl.new('/home', params).inherit_query_shead}'>#{text}</a>"
      end
    else
      text
    end
  end
end
