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
<pre>
パッケージ名: #{name}
レコード数:   #{records.size}
行数:         #{line_count_total(records)}
</pre>
EOF

      @plang_content = <<EOF
<pre>
#{breakdown_detail(records, 10)}
</pre>
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

    def breakdown_detail(records, name_width)
      sorted_plangs(records).map {|name, count|
        percent = (count.to_f / records.size * 100).to_i
        sprintf("%-#{name_width}s  %5d  %3d%%", name, count, percent)
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

