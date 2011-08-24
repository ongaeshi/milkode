# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/03

require 'rubygems'
require 'coderay'
require 'coderay/helpers/file_type'
require 'nokogiri'

# 独自実装したエンコード形式は事前に読み込んでおけばOK
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../../../../vendor')
require 'coderay/encoders/html_anchor'

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
        html(
             :wrap => nil,
             :line_numbers => :table,
             :css => :class,
             :highlight_lines => @highlight_lines,
             :line_number_start => @line_number_start
             )
      milkode_ornament(html)
    end

    def to_html_anchor
      html = CodeRay.scan(@content, file_type).
        html(
             :wrap => nil,
             :line_numbers => :table,
             :css => :class,
             :highlight_lines => @highlight_lines,
             :line_number_start => @line_number_start
             )
      
      html_doc = Nokogiri::HTML(html)
      anchor = create_anchorlink(html_doc.at_css("table.CodeRay td.code pre").inner_html)
      body = milkode_ornament(html)
      return anchor + body
    end

    def milkode_ornament(html)
      a = html.split("\n")

      line_number = @line_number_start
      is_code_content = false

      a.each_with_index do |l, index|
        if (l =~ /  <td class="code"><pre (.*?)>(.*)<tt>/)
          a[index] = "  <td class=\"code\"><pre #{$1}><span #{line_attr(line_number)}>#{$2}</span><tt>"
          is_code_content = true
          line_number += 1
          next
        elsif (l =~ %r|</tt></pre></td>|)
          is_code_content = false
        end

        if (is_code_content)
          if (l =~ %r|</tt>(.*)<tt>|)
            a[index] = "</tt><span #{line_attr(line_number)}>#{$1}</span><tt>"
            line_number += 1
          end
        end
      end
          
      a.join("\n") + "\n"
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


