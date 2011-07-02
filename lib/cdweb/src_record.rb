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
  class SrcRecord
    def initialize(record)
      @record = record
    end

    def to_html
      <<EOF
#{to_html_code(@record.content, file_type(filename))}
EOF
    end

    private
    
    def filename
      @record.shortpath
    end

    def to_html_code(code, kind)
      CodeRay.scan(code, kind).
        html(
             :wrap => nil,
             :line_numbers => :table,
             :css => :class
             )
    end
    
    def file_type(filename)
      case File.extname(filename)
      when ".el"
        :scheme
      else
        CodeRay::FileType.fetch filename, :plaintext
      end
    end
  end
end


