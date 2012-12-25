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
    attr_reader :page
    
    DISP_NUM = 20              # 1ページの表示数
    LIMIT_NUM = 50             # 最大検索ファイル数
    NTH = 3                    # 表示範囲
    COL_LIMIT = 200            # 1行の桁制限

    MATH_FILE_DISP  = 3        # マッチファイルの最大表示数
    MATH_FILE_LIMIT = MATH_FILE_DISP + 1 # マッチファイルの検索リミット数

    def initialize(path, params, query)
      @path = path
      @params = params
      @q = query
      @page = params[:page].to_i || 0
      @offset = params[:offset].to_i
      @line = params[:line].to_i
      @is_onematch = params[:onematch] == 'on'
      @is_sensitive = params[:sensitive] == 'on'

      # 検索1 : クエリーそのまま
      @records, @total_records = Database.instance.search(@q.keywords, @q.multi_match_keywords, @q.packages, path, @q.fpaths, @q.suffixs, @q.fpath_or_packages, @offset, LIMIT_NUM)
      grep_contents(@q.keywords)

      # 検索2 : マッチしなかった時におすすめクエリーがある場合
      if @match_records.empty? && recommended_fpath_or_packages?
        # おすすめクエリーに変換
        q2 = @q.conv_head_keyword_to_fpath_or_packages

        # 検索
        @records, @total_records = Database.instance.search(q2.keywords, q2.multi_match_keywords, q2.packages, path, q2.fpaths, q2.suffixs, q2.fpath_or_packages, @offset, LIMIT_NUM)

        # 再grep
        grep_contents(q2.keywords)
      end
      
      # 検索3 : マッチするファイル
      @match_files = []
      if @offset == 0 && @line == 0
        t = 0

        if (@path != "")
          @match_files, t = Database.instance.search([], @q.multi_match_keywords, @q.packages, path, @q.fpaths + @q.keywords, @q.suffixs, @q.fpath_or_packages, @offset, MATH_FILE_LIMIT)
        else
          @match_files, t = Database.instance.search([], @q.multi_match_keywords, @q.packages, path, @q.fpaths, @q.suffixs, @q.fpath_or_packages + @q.keywords, @offset, MATH_FILE_LIMIT)
        end
      end
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
      
      <<EOF
#{recommended_contents}
#{match_groups.map{|g|result_match_record(g)}.join}
EOF
    end

    def recommended_contents
      contents = []

      str = recommended_query_contents
      contents << str unless str.empty?

      str = match_files_contents
      contents << str unless str.empty?

      unless contents.empty?
        contents.join
      else
        ""
      end
    end

    def recommended_gotoline?
      @q.keywords.size == 1 && @q.only_keywords && Util::sub_gotoline_keyword?(@q.keywords[0])
    end

    def recommended_fpath_or_packages?
      @q.keywords.size >= 2 && @q.only_keywords
    end

    def recommended_query_contents
      if recommended_gotoline?
        conv_query   = @q.conv_gotoline
        tmpp         = @params.clone
        tmpp[:query] = conv_query.query_string
        url          = Mkurl.new(@path, tmpp).inherit_query_shead
        <<EOS
<dt class='result-file'>#{img_icon('document-new-4.png')}<a href='#{url}'>#{conv_query.query_string}</a></dt>
<hr>
EOS
      elsif recommended_fpath_or_packages?
        conv_query   = @q.conv_head_keyword_to_fpath_or_packages
        tmpp         = @params.clone
        tmpp[:query] = conv_query.query_string
        url          = Mkurl.new(@path, tmpp).inherit_query_shead
        <<EOS
<dt class='result-file'>#{img_icon('document-new-4.png')}<a href='#{url}'>#{conv_query.query_string}</a></dt>
<hr>
EOS
      else
        ""
      end
  end
    
    def match_files_contents
      unless @match_files.empty?
        is_and_more = @match_files.size >= MATH_FILE_LIMIT
        @match_files = @match_files[0..MATH_FILE_DISP-1]
        conv_query = (@path != "") ? @q.conv_keywords_to_fpath : @q.conv_keywords_to_fpath_or_packages
        tmpp = @params.clone
        tmpp[:query] = conv_query.query_string
        url = Mkurl.new(@path, tmpp).inherit_query_shead
        <<EOF
#{@match_files.map {|record| result_record(DocumentRecord.new(record))}.join}
#{"<a href='#{url}'>...and more</a></a>" if is_and_more}
<hr>
EOF
      else
        ""
      end
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

    private

    MatchRecord = Struct.new(:record, :match_line)

    def grep_contents(keywords)
      @match_records = []
      @end_index = @next_index = @records.size
      @next_line = nil

      @records.each_with_index do |record, index|
        if (Util::larger_than_oneline(record.content))

          if @is_onematch
            grep = Grep.new(record.content)
            match_line = grep.one_match_and(keywords, @is_sensitive)
            @match_records << MatchRecord.new(record, match_line) if match_line

            if @match_records.size >= DISP_NUM
              @end_index = index
              @next_index = index + 1
              break
            end
          else
            break if grep_match_lines_stopover(record, index, keywords)
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

    def grep_match_lines_stopover(record, index, keywords)
      grep = Grep.new(record.content)      
      r = grep.match_lines_stopover(keywords, DISP_NUM - @match_records.size, (index == 0) ? @line : 0, @is_sensitive)

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

      url = "/home/" + record_link(record)
      
      <<EOS
    <dt class='result-record'><a href='#{url + "#n#{coderay.highlight_lines[0]}"}'>#{Util::relative_path record.shortpath, @path}</a>#{result_refinement(record)}</dt>
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

    def refinement_suffix(suffix)
      params = @params.clone
      params[:query] = [@params[:query], "s:#{suffix}"].join(" ")
      "/home/" + Mkurl.new(@path, params).inherit_query_shead
    end

    def refinement_directory(path)
      "/home/" + Mkurl.new(path, @params).inherit_query_shead
    end

    def result_refinement(record)
      refinements = []

      # 拡張子で絞り込み
      refinements << "<a href='#{refinement_suffix(record.suffix)}'>.#{record.suffix}で絞り込み</a>" if record.suffix

      # ディレクトリで絞り込み
      path    = Util::relative_path(record.shortpath, @path)
      dirname = path.to_s.split('/')[-2]
      refinements << "<a href='#{refinement_directory(record.shortpath + '/..')}'>#{dirname}/以下で再検索</a>" if dirname

      unless refinements.empty?
        space1            = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
        space2            = '&nbsp;&nbsp;,&nbsp;&nbsp;'

        <<EOF
#{space1}<span id="result-refinement">[#{refinements.join(space2)}]</span>
EOF
      else
        ''
      end

    end

  end
end



