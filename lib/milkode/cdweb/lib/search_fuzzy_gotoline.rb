# -*- coding: utf-8 -*-
#
# @file 
# @brief  曖昧ジャンプ
# @author ongaeshi
# @date   2012/07/08

require 'milkode/cdweb/lib/query'
require 'milkode/cdweb/lib/grep'
require 'milkode/cdweb/lib/mkurl'
require 'milkode/common/util'

module Milkode
  class SearchFuzzyGotoLine
    attr_reader :total_records
    attr_reader :match_records
    attr_reader :next_index
    attr_reader :end_index
    
    DISP_NUM = 20              # 1ページの表示数
    LIMIT_NUM = 50             # 最大検索ファイル数
    NTH = 3                    # 表示範囲
    COL_LIMIT = 200            # 1行の桁制限

    def initialize(path, params, query)
      @path = path
      @params = params
      @q = query
      @page = params[:page].to_i || 0
      @offset = params[:offset].to_i

      # 検索クエリを解析
      gotolines = Util::parse_gotoline(@q.gotolines + @q.keywords)
      @gotoline = gotolines[0]

      # 検索
      fpaths = @q.fpaths + @gotoline[0]
      @records, @total_records = Database.instance.search([], @q.multi_match_keywords, @q.packages, path, fpaths, @q.suffixs, @q.fpath_or_packages, @offset, LIMIT_NUM)

      # 検索結果を表示
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
        # 近接マッチ無効
        g << [m]
      end
      
      <<EOF
#{match_groups.map{|g|result_match_record(g)}.join}
EOF
    end

    def html_pagination
      return "" if @q.empty?
      return "" if next_offset >= @total_records

      return <<EOF
<div class='pagination pagination-centered'>
#{pagination_link(next_offset, @next_line, "next >>")}
</div>
EOF
    end

    def match_num
      @match_records.size
    end

    def directjump?
      match_num == 1
    end

    def directjump_url
      path   = File.join('/home', @match_records[0].record.shortpath)
      lineno = "#n#{@gotoline[1]}"
      Mkurl.new(path, @params).inherit_query_shead + lineno
    end

    private

    MatchRecord = Struct.new(:record, :match_line)

    def grep_contents
      @match_records = []
      @end_index = @next_index = @records.size
      @next_line = nil

      @records.each_with_index do |record, index|
        lineidx = @gotoline[1] - 1
        
        if (lineidx < record.content.split("\n").size)
          @match_records << MatchRecord.new(record, Grep::MatchLineResult.new(lineidx, nil))

          if @match_records.size >= DISP_NUM
            @end_index  = index
            @next_index = index + 1
            break
          end
        end
      end
    end

    def result_match_record(match_group)
      record = match_group[0].record

      first_index = match_group[0].match_line.index - NTH
      last_index  = match_group[-1].match_line.index + NTH
      match_lines = match_group.map{|m| m.match_line}

      coderay = CodeRayWrapper.new(record.content, record.shortpath, match_lines)
      coderay.col_limit(COL_LIMIT)
      coderay.set_range(first_index..last_index)

      url = "/home/" + record_link(record)
      
      <<EOS
    <dt class='result-record'><a href='#{url + "#n#{coderay.highlight_lines[0]}"}'>#{Util::relative_path record.shortpath, @path}</a></dt>
    <dd>
#{coderay.to_html_anchorlink(url)}
    </dd>
EOS
    end

    def pagination_link(offset, line, label)
      tmpp = @params.clone
      tmpp[:offset] = offset.to_s
      tmpp[:line] = line.to_s
      href = Mkurl.new("", tmpp).inherit_query_shead_offset
      pagination_span("<a href='#{href}' rel='next'>#{label}</a>")
    end

    def pagination_span(content)
      "<ul><li>#{content}</li></ul>\n"
    end

    def result_record(record)
      <<EOS
    <dt class='result-file'>#{file_or_dirimg(true)}<a href='#{"/home/" + record_link(record)}'>#{Util::relative_path record.shortpath, @path}</a></dt>
EOS
    end

    def record_link(record)
      Mkurl.new(record.shortpath, @params).inherit_query_shead
    end

  end
end


