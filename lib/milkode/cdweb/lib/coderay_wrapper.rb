# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/03

require 'rubygems'
require 'coderay'
require 'coderay/helpers/file_type'
require 'milkode/common/util'
require 'milkode/cdweb/lib/coderay_html2'
require 'milkode/cdweb/lib/coderay_php_utf8'
require 'milkode/cdweb/lib/web_setting'

module Milkode
  class CodeRayWrapper
    attr_reader :line_number_start
    attr_reader :highlight_lines
    
    def initialize(content, filename, match_lines = [], keywords = [])
      @content = content
      @filename = filename
      @match_lines = match_lines
      @highlight_lines = match_lines.map{|v|v.index+1}
      @line_number_start = 1
      @keywords = keywords
    end

    def col_limit(limit_num)
      content_a = @content.split("\n")

      @content = content_a.map{|v|
        if (v.length > limit_num)
          v[0...limit_num] + " ..."
        else
          v
        end
      }.join("\n")
    end

    def set_range(range)
      content_a = @content.split("\n")
      range = limit_range(range, content_a)
      @content = content_a[range].join("\n")
      @line_number_start = range.first + 1
    end

    def limit_range(range, array)
      Range.new(range.first < 0 ? 0 : range.first,
                range.last >= array.size ? array.size - 1 : range.last)
    end

    def to_html
      CodeRay.scan(@content, file_type).
        html2(
              :wrap => nil,
              :line_numbers => :table,
              :css => :class,
              :highlight_lines => @highlight_lines,
              :line_number_start => @line_number_start,
              :line_number_anchors => false,
              :onclick_copy_line_number => true,
              :onclick_copy_prefix => "/#{@filename}:",
              :keywords => @keywords
              )
    end

    def to_html_anchorlink(url)
      CodeRay.scan(@content, file_type).
        html2(
              :wrap => nil,
              :line_numbers => :table,
              :css => :class,
              :highlight_lines => @highlight_lines,
              :line_number_start => @line_number_start,
              :line_number_anchors => 'n',
              :line_number_anchor_url => url,
              :keywords => @keywords
              )
    end

    def file_type
      @setting = WebSetting.new
      @extname = File.extname(@filename)
      @p_extname = "^\\#{@extname}$"
      if @setting.eliminate_extname.split(" ").grep(/#{@p_extname}/).size > 0
          @filename = File.basename(@filename, @extname)
          @extname = File.extname(@filename)
      end
      case @extname
      when ".php"
        :php_utf8
      when ".el"
        # :scheme
        CodeRay::FileType.fetch @filename, :plaintext
      else
        CodeRay::FileType.fetch @filename, :plaintext
      end
    end
  end
end


