# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/05/04

module Milkode
  class InfoHome
    attr_reader :record_content
    attr_reader :total_records

    def initialize
      packages       = Database.instance.packages(nil)
      @total_records = packages.size

      # table
      table_header = "<tr><th>名前</th><th>レコード数</th><th>行数</th><tr>"

      table_content = packages.map {|name|
        records = Database.instance.package_records(name)
        "<tr><td><a href='/info/#{name}'>#{name}</a></td><td>#{records.size}<td/><td>#{line_count_total(records)}</td></tr>"
      }.join("\n")

      @record_content = <<EOF
<table>
#{table_header}
#{table_content}
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
  end
end

