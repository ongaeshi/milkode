# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/18

require 'rubygems'
require 'rack'

module CodeRay
module Encoders
  class HTML2 < HTML
    register_for :html2

    def text_token text, kind
      # p "#{kind}: #{text}"
      super
    end

    # [ref] CodeRay::Encoders::HTML#finish (coderay-1.0.5/lib/coderay/encoders/html.rb:219)
    def finish options
      @out = ornament_line_attr(options)

      unless @opened.empty?
        warn '%d tokens still open: %p' % [@opened.size, @opened] if $CODERAY_DEBUG
        @out << '</span>' while @opened.pop
        @last_opened = nil
      end
      
      @out.extend Output
      @out.css = @css
      if options[:line_numbers]
        # Numbering.number! @out, options[:line_numbers], options
        HTML2::number! @out, options[:line_numbers], options
      end
      @out.wrap! options[:wrap]
      @out.apply_title! options[:title]
      
      if defined?(@real_out) && @real_out
        @real_out << @out
        @out = @real_out
      end
      
      @out
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
      r << "id=\"n#{no}\""
      r << "class=\"highlight-line\"" if highlight_lines.include?(no)
      r.join(" ")
    end

    # [ref] CodeRay::Encoders::Numberling#number! (coderay-1.0.5/lib/coderay/encoders/numbering.rb:8)
    def self.number! output, mode = :table, options = {}
      return self unless mode

      options = DEFAULT_OPTIONS.merge options

      start = options[:line_number_start]
      unless start.is_a? Integer
        raise ArgumentError, "Invalid value %p for :line_number_start; Integer expected." % start
      end
      
      anchoring = create_anchor(options)
      
      bold_every = options[:bold_every]
      highlight_lines = options[:highlight_lines]
      bolding =
        if bold_every == false && highlight_lines == nil
          anchoring
        elsif highlight_lines.is_a? Enumerable
          highlight_lines = highlight_lines.to_set
          proc do |line|
          if highlight_lines.include? line
            "<strong class=\"highlighted\">#{anchoring[line]}</strong>"  # highlighted line numbers in bold
          else
            anchoring[line]
          end
        end
        elsif bold_every.is_a? Integer
          raise ArgumentError, ":bolding can't be 0." if bold_every == 0
          proc do |line|
          if line % bold_every == 0
            "<strong>#{anchoring[line]}</strong>"  # every bold_every-th number in bold
          else
            anchoring[line]
          end
        end
        else
          raise ArgumentError, 'Invalid value %p for :bolding; false or Integer expected.' % bold_every
        end
      
      line_count = output.count("\n")
      position_of_last_newline = output.rindex(RUBY_VERSION >= '1.9' ? /\n/ : ?\n)
      if position_of_last_newline
        after_last_newline = output[position_of_last_newline + 1 .. -1]
        ends_with_newline = after_last_newline[/\A(?:<\/span>)*\z/]
        line_count += 1 if not ends_with_newline
      end
      
      case mode
      when :inline
        max_width = (start + line_count).to_s.size
        line_number = start
        nesting = []
        output.gsub!(/^.*$\n?/) do |line|
          line.chomp!
          open = nesting.join
          line.scan(%r!<(/)?span[^>]*>?!) do |close,|
            if close
              nesting.pop
            else
              nesting << $&
            end
          end
          close = '</span>' * nesting.size
          
          line_number_text = bolding.call line_number
          indent = ' ' * (max_width - line_number.to_s.size)  # TODO: Optimize (10^x)
          line_number += 1
          "<span class=\"line-numbers\">#{indent}#{line_number_text}</span>#{open}#{line}#{close}\n"
        end

      when :table
        line_numbers = (start ... start + line_count).map(&bolding).join("\n")
        line_numbers << "\n"
        line_numbers_table_template = Output::TABLE.apply('LINE_NUMBERS', line_numbers)

        output.gsub!(/<\/div>\n/, '</div>')
        output.wrap_in! line_numbers_table_template
        output.wrapped_in = :div

      when :list
        raise NotImplementedError, 'The :list option is no longer available. Use :table.'

      else
        raise ArgumentError, 'Unknown value %p for mode: expected one of %p' %
          [mode, [:table, :inline]]
      end

      output
    end

    def self.create_anchor(options)
      anchor_prefix = options[:line_number_anchors]
      anchor_prefix = 'line' if anchor_prefix == true
      anchor_prefix = anchor_prefix.to_s[/\w+/] if anchor_prefix

      if anchor_prefix
        anchor_url = options[:line_number_anchor_url] || ""

        proc do |line|
          line = line.to_s
          anchor = anchor_prefix + line
          "<a href=\"#{anchor_url}##{anchor}\" name=\"#{anchor}\">#{line}</a>"
        end
      elsif options[:onclick_copy_line_number]
        prefix = options[:onclick_copy_prefix] || ""
        proc do |line|
          "<a href=\"#lineno-modal\" data-toggle=\"modal\" onclick=\"lineno_setup('#{prefix}', '#{line.to_s}');\" title=\"Display line number\">#{line.to_s}</a>"
        end
      else
        proc { |line| line.to_s }  # :to_s.to_proc in Ruby 1.8.7+
      end
    end
  end
end
end



