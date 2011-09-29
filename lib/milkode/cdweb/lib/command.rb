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
require 'milkode/cdweb/lib/mkurl'
require 'milkode/common/util'

module Milkode
  def view(record, params, before)
    @title = record.shortpath
    @path = record.shortpath

    q = params[:query] && Query.new(params[:query]) 

    if (Util::larger_than_oneline(record.content) and q and !q.keywords.empty?)
      grep = Grep.new(record.content)
      match_lines = grep.match_lines_and(q.keywords)
      @record_content = CodeRayWrapper.new(record.content, record.shortpath, match_lines).to_html_anchor
    else
      @record_content = CodeRayWrapper.new(record.content, record.shortpath).to_html
    end
    
    @elapsed = Time.now - before
    haml :view
  end

  def search(path, params, before)
    @path = path
    query = Query.new(params[:query])
    @title = "'#{query.query_string}' in #{path_title(path)}"

    if (query.keywords.size > 0)
      searcher = SearchContents.new(path, params, query)
    else
      searcher = SearchFiles.new(path, params, query)
    end
    
    @total_records = searcher.total_records
    @range = searcher.data_range
    @record_content = "<dl class='autopagerize_page_element'>#{searcher.html_contents}</dl>#{searcher.html_pagination}";
    @match_num = searcher.match_num
    @elapsed = Time.now - before
    haml :search
  end

  def filelist(path, params, before)
    @title = filelist_title(path)
    @path = path
    fileList = Database.instance.fileList(path)
    @total_records = fileList.size
    @record_content = fileList.map do |v|
      "<dt class='result-file'>#{file_or_dirimg(v[1])}<a href='#{Mkurl.new('/home/' + v[0], params).inherit_query_shead}'>#{File.basename v[0]}</a></dt>"
    end.join
    @elapsed = Time.now - before
    haml :filelist
  end

  def file_or_dirimg(is_file)
    src = (is_file) ? '/images/file.png' : '/images/directory.png'
    "<img alt='' style='vertical-align:bottom; border: 0; margin: 1px;' src='#{src}'>"
  end
end
