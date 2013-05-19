# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/05/04

require 'milkode/cdweb/lib/database'
require 'milkode/common/plang_detector'
require 'milkode/cdweb/lib/mkurl'

module Milkode
  class InfoPackage
    attr_reader :summary_content
    attr_reader :plang_content

    def initialize(name)
      records = Database.instance.package_records(name)
      # plangs  = sorted_plangs(records)
      
      @summary_content = <<EOF
<table class="table-striped table-bordered table-condensed">
  <tr><td>ファイル数</td><td align="right">#{records.size}</td></tr>
  <tr><td>行数</td><td align="right">#{line_count_total(records)}</td></tr>
</table>
EOF

      @plang_content = <<EOF
<table class="table-striped table-bordered table-condensed">
#{breakdown_detail(name, records)}
</table>
EOF
    end

    def line_count_total(records)
      records.reduce(0) do |total, record|
        begin
          unless record.content.nil?
            total + record.content.count($/) + 1
          else
            total
          end
        rescue ArgumentError
          # warning_alert("invalid byte sequence : #{record.path}")
          total
        end
      end
    end

    def breakdown_detail(package_name, records)
      sorted_plangs(records).map {|name, count, lang|
        percent = (count.to_f / records.size * 100).to_i

        params = { :query => lang_to_query(lang) }

        if params[:query] != ""
          url = "/home/" + Mkurl.new(package_name, params).inherit_query_shead
          "<tr><td>#{name}</td><td align=\"right\"><a href=\"#{url}\">#{count}</a></td><td align=\"right\">#{percent}%</td></tr>"
        else
          "<tr><td>#{name}</td><td align=\"right\">#{count}</td><td align=\"right\">#{percent}%</td></tr>"
        end
      }.join("\n")
    end

    def lang_to_query(lang)
      # @memo
      # この実装には問題がある。Makefileなどの検索クエリが正しくない。
      # 正しく実装するには AND, OR 検索を実装する必要がある
      result = []
      result << lang.suffixs.map{|v|"s:#{v}"}.join(" ")      if lang.suffixs
      result << lang.filenames.map{|v|"f:#{v}"}.join(" ")    if lang.filenames
      result << lang.filepatterns.map{|v|"f:#{v}"}.join(" ") if lang.filepatterns
      result.join(" ")
    end

    def sorted_plangs(records)
      total = {}
      
      records.each do |record|
        lang = PlangDetector.new(record.restpath)
        
        if total[lang.name]
          total[lang.name][0] += 1
        else
          total[lang.name] = [1, lang]
        end
      end

      total.map {|name, data|
        [name, data[0], data[1]]
      }.sort {|a, b|
        if (a[0] == PlangDetector::UNKNOWN)
          -1
        elsif (b[0] == PlangDetector::UNKNOWN)
          1
        else
          a[1] <=> b[1]
        end
      }.reverse
    end
  end
end

