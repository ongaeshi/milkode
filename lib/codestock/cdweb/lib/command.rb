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
    @path = topic_path(record.shortpath)
    @package_name = package_name(record.shortpath)
    @record_content = CodeRayWrapper.html_memfile(record.content, record.shortpath)
    @elapsed = Time.now - before
    haml :view
  end

  def search(path, params, before)
    @title = path_title(path)
    @search_op = params[:search_op]
    searcher = Searcher.new(path, params[:keyword], params[:page].to_i)
    @keyword = searcher.keyword
    @package_name = package_name(path)
    @filepath = topic_path(path)
    @total_records = searcher.total_records
    @range = searcher.page_range
    @record_content = searcher.html_contents  + searcher.html_pagination;
    @elapsed = Time.now - before
    haml :search
  end

  def filelist(path, before)
    @title = path_title(path)
    fileList = Database.instance.fileList(path)
    @keyword = ""
    @package_name = package_name(path)
    @filepath = topic_path(path)
    @total_records = fileList.size
    @record_content = fileList.map {|v| "<dt class='result-record'><a href='/home/#{escape_path(v[0])}'>#{File.basename v[0]}</a></dt>" }
    @elapsed = Time.now - before
    haml :filelist
  end

  # --------------

  def path_title(path)
    (path == "") ? "Package List" : path
  end
  
  def package_name(path)
    (path == "") ? 'root' : path.split('/')[0]
  end

  def topic_path(path)
    href = '/home'
    path.split('/').map {|v|
      href += '/' + v
      "<a href='#{escape_path(href)}'>#{v}</a>"
    }.join(' / ')
  end
end
