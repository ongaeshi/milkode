# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/05/04

require 'milkode/cdweb/lib/database'
require 'milkode/common/plang_detector'

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
#{breakdown_detail(records)}
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

    def breakdown_detail(records)
      sorted_plangs(records).map {|name, count|
        percent = (count.to_f / records.size * 100).to_i
        "<tr><td>#{name}</td><td align=\"right\">#{count}</td><td align=\"right\">#{percent}%</td></tr>"
      }.join("\n")
    end

    def sorted_plangs(records)
      total = {}
      
      records.each do |record|
        lang = PlangDetector.new(record.restpath)

        if total[lang.name]
          total[lang.name] += 1
        else
          total[lang.name] = 1
        end
      end

      total.map {|name, count|
        [name, count]
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

