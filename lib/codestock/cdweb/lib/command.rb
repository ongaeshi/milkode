# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/11

require 'codestock/cdweb/lib/database'
require 'codestock/cdweb/lib/coderay_wrapper'
require 'codestock/cdweb/lib/searcher'
require 'codestock/cdweb/lib/mkurl'

module CodeStock
  def view(record, params, before)
    @title = record.shortpath
    @path = record.shortpath

    q = Query.new(params[:query])

    unless (q.keywords.empty?)
      grep = Grep.new(record.content)
      match_lines = grep.match_lines_or(q.keywords)
      @record_content = CodeRayWrapper.html_memfile(record.content, record.shortpath, match_lines)
    else
      @record_content = CodeRayWrapper.html_memfile(record.content, record.shortpath)
    end
    
    @elapsed = Time.now - before
    haml :view
  end

  def search(path, params, before)
    @title = path_title(path)
    @path = path
    searcher = Searcher.new(path, params)
    @total_records = searcher.total_records
    @range = searcher.page_range
    @record_content = searcher.html_contents  + searcher.html_pagination;
    @elapsed = Time.now - before
    haml :search
  end

  def filelist(path, params, before)
    @title = path_title(path)
    @path = path
    fileList = Database.instance.fileList(path)
    @total_records = fileList.size
    @record_content = fileList.map {|v| "<dt class='result-record'><a href='#{Mkurl.new('/home/' + v[0], params).inherit_query_shead}'>#{File.basename v[0]}</a></dt>"}
    @elapsed = Time.now - before
    haml :filelist
  end
end
