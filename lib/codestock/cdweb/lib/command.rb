# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/11

require 'codestock/cdweb/lib/database'
require 'codestock/cdweb/lib/coderay_wrapper'
require 'codestock/cdweb/lib/searcher'

module CodeStock
  def view(record, before)
    @title = record.shortpath
    @path = record.shortpath
    @record_content = CodeRayWrapper.html_memfile(record.content, record.shortpath)
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

  def filelist(path, before)
    @title = path_title(path)
    @path = path
    fileList = Database.instance.fileList(path)
    @total_records = fileList.size
    @record_content = fileList.map {|v| "<dt class='result-record'><a href='/home/#{escape_path(v[0])}'>#{File.basename v[0]}</a></dt>" }
    @elapsed = Time.now - before
    haml :filelist
  end
end
