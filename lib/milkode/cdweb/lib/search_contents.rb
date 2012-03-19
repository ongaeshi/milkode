# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/18

require 'milkode/cdweb/lib/query'
require 'milkode/cdweb/lib/grep'
require 'milkode/cdweb/lib/mkurl'
require 'milkode/common/util'

module Milkode
  class SearchContents
    attr_reader :total_records
    attr_reader :elapsed
    attr_reader :page
    
    DISP_NUM = 20              # 1ページの表示数
    LIMIT_NUM = 50             # 最大検索ファイル数
    NTH = 3                    # 表示範囲
    COL_LIMIT = 200            # 1行の桁制限
    
#     DISP_NUM = 1000              # 1ページの表示数
#     LIMIT_NUM = 1000             # 最大検索ファイル数
#     NTH = 3                      # 表示範囲
#     COL_LIMIT = 200              # 1行の桁制限
    
    def initialize(path, params, query)
      @path = path
      @params = params
      @q = query
      @page = params[:page].to_i || 0
      @offset = params[:offset].to_i
      @line = params[:line].to_i
      @is_onematch = params[:onematch]
      @records, @total_records, @elapsed = Database.instance.search(@q.keywords, @q.packages, path, @q.fpaths, @q.suffixs, @offset, LIMIT_NUM)
      grep_contents
    end

    def query
      @q.query_string
    end

    def next_offset
      @offset + @next_index
    end

    def data_range
      @offset..(@offset + @end_index)
    end

    def html_contents
      match_groups = @match_records.reduce([]) do |g, m|
        if (g.empty?)
          g << [m]
        else
          prev = g[-1][-1]

          if (m.match_line.index - prev.match_line.index <= NTH * 2 &&
              m.record.shortpath == prev.record.shortpath)
            g[-1] << m          # グループの末尾に追加
            g
          else
            g << [m]            # 新規グループ
          end
        end

        # 近接マッチ無効
        # g << [m]
      end
      
      match_groups.map{|g|result_match_record(g)}.join
    end
    
    def html_pagination
      return "" if @q.empty?
      return "" if next_offset >= @total_records

      return <<EOF
<div class='pagination'>
#{pagination_link(next_offset, @next_line, "next >>")}
</div>
EOF
    end

    def match_num
      @match_records.size
    end

    private

    MatchRecord = Struct.new(:record, :match_line)

    def grep_contents
      @match_records = []
      @end_index = @next_index = @records.size
      @next_line = nil

      @records.each_with_index do |record, index|
        if (Util::larger_than_oneline(record.content))

          if @is_onematch
            grep = Grep.new(record.content)
            match_line = grep.one_match_and(@q.keywords)
            @match_records << MatchRecord.new(record, match_line) if match_line

            if @match_records.size >= DISP_NUM
              @end_index = index
              @next_index = index + 1
              break
            end
          else
            break if grep_match_lines_stopover(record, index)
          end
        else
          @match_records << MatchRecord.new(record, Grep::MatchLineResult.new(0, nil))

          if @match_records.size >= DISP_NUM
            @end_index = index
            @next_index = index + 1
            break
          end
        end
      end
    end

    def grep_match_lines_stopover(record, index)
      grep = Grep.new(record.content)      
      r = grep.match_lines_stopover(@q.keywords, DISP_NUM - @match_records.size, (index == 0) ? @line : 0)

      r[:result].each do |match_line|
        @match_records << MatchRecord.new(record, match_line) if match_line
      end

      if @match_records.size >= DISP_NUM
        if (r[:next_line] == 0)
          @end_index = index
          @next_index = index + 1
        else
          @end_index = index
          @next_index = index
          @next_line = r[:next_line]
        end
        return true
      end

      return false
    end

    def result_match_record(match_group)
      record = match_group[0].record

      first_index = match_group[0].match_line.index - NTH
      last_index  = match_group[-1].match_line.index + NTH
      match_lines = match_group.map{|m| m.match_line}

      coderay = CodeRayWrapper.new(record.content, record.shortpath, match_lines)
      coderay.col_limit(COL_LIMIT)
      coderay.set_range(first_index..last_index)

      <<EOS
    <dt class='result-record'><a href='#{"/home/" + record_link(record) + "##{coderay.line_number_start}"}'>#{Util::relative_path record.shortpath, @path}</a></dt>
    <dd>
#{coderay.to_html}
    </dd>
EOS
    end

    def pagination_link(offset, line, label)
      tmpp = @params
      tmpp[:offset] = offset.to_s
      tmpp[:line] = line.to_s
      href = Mkurl.new("", tmpp).inherit_query_shead_offset
      pagination_span("<a href='#{href}' rel='next'>#{label}</a>")
    end

    def pagination_span(content)
      "<span class='pagination-link'>#{content}</span>\n"
    end

    def record_link(record)     # 
      Mkurl.new(record.shortpath, @params).inherit_query_shead
    end

  end
end



