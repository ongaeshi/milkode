# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/03

require 'rubygems'
require 'coderay'
require 'coderay/helpers/file_type'

module CodeStock
  class CodeRayWrapper
    def self.html_memfile(content, filename, match_lines = [])
      to_html_code(content, file_type(filename), match_lines)
    end
    
    def self.to_html_code(code, kind, match_lines)
      codestock_ornament(
        CodeRay.scan(code, kind).
        html(
             :wrap => nil,
             :line_numbers => :table,
             :css => :class,
             :highlight_lines => match_lines.map{|v|v.index+1}
             )
      )
    end
    
    def self.file_type(filename)
      case File.extname(filename)
      when ".el"
        :scheme
      else
        CodeRay::FileType.fetch filename, :plaintext
      end
    end

    def self.codestock_ornament(src)
      a = src.split("\n")

      line_number = 1
      is_code_content = false

      a.each_with_index do |l, index|
        if (l =~ /  <td class="code"><pre (.*?)>(.*)<tt>/)
          a[index] = "  <td class=\"code\"><pre #{$1}><span id=\"#{line_number}\">#{$2}</span><tt>"
          is_code_content = true
          line_number += 1
          next
        elsif (l =~ %r|</tt></pre></td>|)
          is_code_content = false
        end

        if (is_code_content)
          if (l =~ %r|</tt>(.*)<tt>|)
            a[index] = "</tt><span id=\"#{line_number}\">#{$1}</span><tt>"
            line_number += 1
          end
        end
      end
          
      a.join("\n") + "\n"
    end
  end
end


