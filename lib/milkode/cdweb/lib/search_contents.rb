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
require 'milkode/cdweb/lib/search_fuzzy_gotoline'

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

    DEFAULT_WIDE_MATCH_RANGE = 7 # 未指定時のワイド検索範囲

    FILTER_BY_PACKAGE_NUM = 8
    FILTER_BY_SUFFIX_NUM  = 8
    FILTER_BY_DIRECTORIES_FILES = 200

    def initialize(path, params, query, suburl, locale)
      @path             = path
      @params           = params
      @q                = query
      @page             = params[:page].to_i || 0
      @offset           = params[:offset].to_i
      @line             = params[:line].to_i
      @is_onematch      = params[:onematch]  == 'on'
      @is_sensitive     = params[:sensitive] == 'on'
      @suburl           = suburl
      @homeurl          = @suburl + "/home/"
      @locale           = locale

      @searcher_fuzzy_gotoline = nil

      # 検索1 : クエリーそのまま
      @records, @total_records, result = Database.instance.search(@q.keywords, @q.multi_match_keywords, @q.packages, path, @q.fpaths, @q.suffixs, @q.fpath_or_packages, @offset, LIMIT_NUM)
      grep_contents(@q.keywords, @q.wide_match_range)

      # 検索2 : マッチしなかった時におすすめクエリーがある場合

      # gotolineモード (test_cdstk.rb:55)
      if @match_records.empty? && recommended_fuzzy_gotoline?
        # 専用の Searcher を作成
        @searcher_fuzzy_gotoline = SearchFuzzyGotoLine.new(@path, @params, @q, @suburl)

        # 結果をコピーする
        @total_records = @searcher_fuzzy_gotoline.total_records
        @match_records = @searcher_fuzzy_gotoline.match_records
        @next_index    = @searcher_fuzzy_gotoline.next_index
        @end_index     = @searcher_fuzzy_gotoline.end_index
        @next_line     = nil
      end

      # ワイド検索範囲
      if @match_records.empty? && recommended_wide_match_range?
        grep_contents(@q.keywords, DEFAULT_WIDE_MATCH_RANGE)

        # 検索範囲0の自動マッチは混乱をまねくのでやめる
        # if @match_records.empty?
        #   grep_contents(@q.keywords, 0)
        # end
      end

      # 先頭をファイル名とみなす自動マッチは混乱をまねくのでやめる
      # if @match_records.empty? && recommended_fpath_or_packages?
      #   # おすすめクエリーに変換
      #   q2 = @q.conv_head_keyword_to_fpath_or_packages
        
      #   # 検索
      #   @records, @total_records = Database.instance.search(q2.keywords, q2.multi_match_keywords, q2.packages, path, q2.fpaths, q2.suffixs, q2.fpath_or_packages, @offset, LIMIT_NUM)
        
      #   # 再grep
      #   grep_contents(q2.keywords, q2.wide_match_range)
      # end
      
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

      # Search4 : Drilldown
      begin 
        @drilldown_packages    = DocumentTable.drilldown(result, "package", FILTER_BY_PACKAGE_NUM)
        @drilldown_directories = make_drilldown_directories(result)
        @drilldown_suffixs     = DocumentTable.drilldown(result, "suffix", FILTER_BY_SUFFIX_NUM)
      rescue Groonga::InvalidArgument
        @drilldown_packages = @drilldown_directories = @drilldown_suffixs = []
      end
    end

    def make_drilldown_directories(result)
      # Return empty if root path
      return [] if @path == ""

      # Drilldown
      files = DocumentTable.drilldown(result, "restpath")
      return [] if files.size > FILTER_BY_DIRECTORIES_FILES
      
      files.map {|v|
        Util::relative_path(v[1], @path.split("/")[1..-1].join("/")).to_s               # 'path/to/file' ->  'to/file' (@path == 'path')
      }.find_all {|v|
        v.include?("/")                                                                 # Extract directory
      }.map {|v|
        v.split("/")[0]                                                                 # 'to/file' -> 'to'
      }.inject(Hash.new(0)) {|hash, v| 
        hash[v] += 1; hash                                                              # Collect hash
      }.map {|key, value|
        [value, key]                                                                    # To Array
      }.to_a
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

      @prev = nil
      
      <<EOF
#{recommended_contents}
#{match_groups.map{|g|result_match_record(g)}.join}
EOF
    end

    def recommended_contents
      contents = []

      str = drilldown_contents
      contents << str unless str.empty?

      # str = recommended_query_contents
      # contents << str unless str.empty?

      str = match_files_contents
      contents << str unless str.empty?

      unless contents.empty?
        contents.join
      else
        ""
      end
    end

    def recommended_fuzzy_gotoline?
      @q.keywords.size == 1 && @q.only_keywords && Util::fuzzy_gotoline_keyword?(@q.keywords[0])
    end

    def recommended_wide_match_range?
      @q.keywords.size >= 2 && @q.wide_match_range_empty?
    end

    def recommended_fpath_or_packages?
      @q.keywords.size >= 2 && @q.only_keywords
    end

    def recommended_query_contents
      result = []
      
      if recommended_fuzzy_gotoline?
        conv_query   = @q.conv_fuzzy_gotoline
        tmpp         = @params.clone
        tmpp[:query] = conv_query.query_string
        url          = Mkurl.new(@path, tmpp).inherit_query_shead
        result << "<dt class='result-file'>#{img_icon('document-new-4.png', @suburl)}<a href='#{url}'>#{conv_query.query_string}</a></dt>"
      end

      if recommended_wide_match_range?
        conv_query   = @q.conv_wide_match_range(0)
        tmpp         = @params.clone
        tmpp[:query] = conv_query.query_string
        w0_url        = Mkurl.new(@path, tmpp).inherit_query_shead

        conv_query   = @q.conv_wide_match_range(1)
        tmpp         = @params.clone
        tmpp[:query] = conv_query.query_string
        w1_url        = Mkurl.new(@path, tmpp).inherit_query_shead

        conv_query   = @q.conv_wide_match_range(DEFAULT_WIDE_MATCH_RANGE)
        tmpp         = @params.clone
        tmpp[:query] = conv_query.query_string
        url          = Mkurl.new(@path, tmpp).inherit_query_shead

        result << "<dt class='result-file'>#{img_icon('document-new-4.png', @suburl)}<a href='#{url}'>#{conv_query.query_string}</a> (<a href='#{w0_url}'>w:0</a>, <a href='#{w1_url}'>w:1</a>)</dt>"
      end
      
      if recommended_fpath_or_packages?
        conv_query   = @q.conv_head_keyword_to_fpath_or_packages
        tmpp         = @params.clone
        tmpp[:query] = conv_query.query_string
        url          = Mkurl.new(@path, tmpp).inherit_query_shead
        result << "<dt class='result-file'>#{img_icon('document-new-4.png', @suburl)}<a href='#{url}'>#{conv_query.query_string}</a></dt>"
      end

      unless result.empty?
        result.join("\n") + "<hr>\n"
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

    def directjump?
      @searcher_fuzzy_gotoline && @searcher_fuzzy_gotoline.directjump?
    end

    def directjump_url
      @searcher_fuzzy_gotoline.directjump_url
    end

    private

    MatchRecord = Struct.new(:record, :match_line)

    def grep_contents(keywords, wide_match_range)
      @match_records = []
      @end_index = @next_index = @records.size
      @next_line = nil

      @records.each_with_index do |record, index|
        if (Util::larger_than_oneline(record.content))
          if grep_match_lines_stopover(record, index, keywords, wide_match_range)
            break
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

    def grep_match_lines_stopover(record, index, keywords, wide_match_range)
      grep = Grep.new(record.content)

      if @is_onematch
        r = grep.one_match_and(keywords, @is_sensitive, wide_match_range)
      else
        r = grep.match_lines_stopover(keywords, DISP_NUM - @match_records.size, (index == 0) ? @line : 0, @is_sensitive, wide_match_range)
      end

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

      coderay = CodeRayWrapper.new(record.content, record.shortpath, match_lines, @q.keywords)
      coderay.col_limit(COL_LIMIT)
      coderay.set_range(first_index..last_index)

      url = @homeurl + record_link(record)

      path = Util::relative_path(record.shortpath, @path)

      if path != @prev
#         dt = <<EOS
#     <dt class='result-record'><a href='#{url + "#n#{coderay.highlight_lines[0]}"}'>#{path}</a>#{result_refinement(record)}</dt>
# EOS
        dt = <<EOS
    <dt class='result-record'><a href='#{url + "#n#{coderay.highlight_lines[0]}"}'>#{path}</a></dt>
EOS
        @prev = path
      else
        dt = "    <dt class='result-record-empty'></dt>"
      end
      
      <<EOS
    #{dt}
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
      filename = Util::relative_path(record.shortpath, @path).to_s
      filename = Util::highlight_keywords(filename, @q.keywords, 'highlight-filename')
      
      <<EOS
    <dt class='result-file'>#{file_or_dirimg(true, @suburl)}<a href='#{@homeurl + record_link(record)}'>#{filename}</a></dt>
EOS
    end

    def record_link(record)
      Mkurl.new(record.shortpath, @params).inherit_query_shead
    end

    def refinement_suffix(suffix)
      params = @params.clone
      params[:query] = [@params[:query], "s:#{suffix}"].join(" ")
      @homeurl + Mkurl.new(@path, params).inherit_query_shead
    end

    def refinement_directory(path)
      @homeurl + Mkurl.new(path, @params).inherit_query_shead
    end

    def result_refinement(record)
      refinements = []

      # 拡張子で絞り込み
      refinements << "<a href='#{refinement_suffix(record.suffix)}'>.#{record.suffix}</a>" if record.suffix

      # ディレクトリで絞り込み
      path    = Util::relative_path(record.shortpath, @path)
      dirname = path.to_s.split('/')[-2]
      refinements << "<a href='#{refinement_directory(record.shortpath + '/..')}'>#{dirname}/</a>" if dirname

      unless refinements.empty?
        space1            = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'
        space2            = '&nbsp;&nbsp;,&nbsp;&nbsp;'

        <<EOF
# #{space1}<span id="result-refinement">#{I18n.t(:filter, {locale: @locale})} [#{refinements.join(space2)}]</span>
EOF
      else
        ''
      end
    end

    def refinement_pathdir(dir)
      refinement_directory(File.join(@path, dir))
    end

    def drilldown_contents
      contents = []
      
      result = drilldown_content(@drilldown_packages, I18n.t(:filter_by_package, {locale: @locale}), method(:refinement_directory))
      contents << result unless result.empty?

      result = drilldown_content(@drilldown_directories, I18n.t(:filter_by_directory, {locale: @locale}), method(:refinement_pathdir), '', '/', true)
      contents << result unless result.empty?

      result = drilldown_content(@drilldown_suffixs, I18n.t(:filter_by_suffix, {locale: @locale}), method(:refinement_suffix), '.')
      contents << result unless result.empty?

      unless contents.empty?
        contents.join + "<hr>\n"
      else
        ""
      end
    end

    def drilldown_content(array, title, to_url, prefix = "", suffix = "", disp_if_one = false)
      unless array.empty? || (!disp_if_one && array.size == 1)
        contents = []

        array.each_with_index do |v, index|
          if v[0] != 0
            contents << "<strong><a href=\"#{to_url.call(v[1])}\" #{v[1]}(#{v[0]})>#{prefix + v[1] + suffix}</a></strong> (#{v[0]})"
          else
            contents << "..."
          end
        end

        "<div class=\"filter_list\">#{title}: " + contents.join("&nbsp;&nbsp;&nbsp;") + "</div>"
      else
        ""
      end
    end

  end
end



