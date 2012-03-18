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
require 'milkode/cdweb/lib/my_nokogiri'

module CodeRay
module Encoders
  class HTML2 < HTML
    register_for :html2

    def text_token text, kind
      # p "#{kind}: #{text}"
      super
    end

    def finish options
      @out = ornament_line_attr(options)
      super
    end

    def ornament_line_attr(options)
      # p options
      line_number = options[:line_number_start]

      lines = @out.split("\n")

      lines.map{|l|
        line_number += 1
        "<span #{line_attr(line_number - 1, options[:highlight_lines])}>#{l}</span>"
      }.join("\n") + "\n"
    end

    def line_attr(no, highlight_lines)
      r = []
      r << "id=\"#{no}\""
      r << "class=\"highlight-line\"" if highlight_lines.include?(no)
      r.join(" ")
    end
  end
end
end

module Milkode
  class CodeRayWrapper
    attr_reader :line_number_start
    
    def initialize(content, filename, match_lines = [])
      @content = content
      @filename = filename
      @match_lines = match_lines
      @highlight_lines = match_lines.map{|v|v.index+1}
      @line_number_start = 1
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
      html = CodeRay.scan(@content, file_type).
        html2(
             :wrap => nil,
             :line_numbers => :table,
             :css => :class,
             :highlight_lines => @highlight_lines,
             :line_number_start => @line_number_start,
             :line_number_anchors => false
             )

      if (is_ornament?)
        html_doc = MyNokogiri::HTML(html)
        add_spanid(html_doc)
      else
        html
      end
    end

    def to_html_anchor
      html = CodeRay.scan(@content, file_type).
        html2(
             :wrap => nil,
             :line_numbers => :table,
             :css => :class,
             :highlight_lines => @highlight_lines,
             :line_number_start => @line_number_start,
             :line_number_anchors => false
             )

      if (is_ornament?)
        html_doc = MyNokogiri::HTML(html)
        # anchor = create_anchorlink(html_doc.at_css("table.CodeRay td.code pre").inner_html)
        # body = add_spanid(html_doc)
        # anchor + body
        add_spanid(html_doc)
      else
        html
      end
    end

    def add_spanid(html_doc)
      # preに<span id="行番号"> を付ける
      table = html_doc.at_css("table.CodeRay")
      pre = table.at_css("td.code pre")
      pre.inner_html = add_spanid_in(pre.inner_html)
      
      # 結果を文字列で返す
      table.to_html
    end

    def add_spanid_in(html)
      lines = html.split("\n")
      line_number = @line_number_start

      lines.map {|l|
        line_number += 1
        "<span #{line_attr(line_number - 1)}>#{l}</span>"
      }.join("\n") + "\n"
    end

    def file_type
      case File.extname(@filename)
      when ".el"
        :scheme
      else
        CodeRay::FileType.fetch @filename, :plaintext
      end
    end

    def line_attr(no)
      r = []
      r << "id=\"#{no}\""
      r << "class=\"highlight-line\"" if @highlight_lines.include?(no)
      r.join(" ")
    end

    def is_ornament?
      false
      # Util::larger_than_oneline(@content)
    end

    ## -- obsolate --
    ANCHOR_OFFSET = 3
    def create_anchorlink(str)
      if @highlight_lines
        lines = str.split("\n")

        codes = @highlight_lines.map {|no|
          "  <tr><td class=\"line_numbers\">#{no}</td> <td class=\"code\"><pre><a href=\"##{[no - ANCHOR_OFFSET, 1].max}\">#{lines[no - 1]}</a></pre></td> </tr>"
        }.join("\n")
        
        <<EOF
<span class="match-num">#{@highlight_lines.size} results</span>
<table class="CodeRay anchor-table">
#{codes}
</table>
<p>
EOF
      else
        ""
      end
    end

  end
end


