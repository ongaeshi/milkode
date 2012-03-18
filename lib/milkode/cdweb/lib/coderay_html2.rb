# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/18

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



