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
    def self.html_memfile(content, filename)
      to_html_code(content, file_type(filename))
    end
    
    def self.to_html_code(code, kind)
      CodeRay.scan(code, kind).
        html(
             :wrap => nil,
             :line_numbers => :table,
             :css => :class
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
  end
end


