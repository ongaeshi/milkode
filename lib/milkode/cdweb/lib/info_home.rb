# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/05/04

module Milkode
  class InfoHome
    attr_reader :record_content
    attr_reader :summary_content

    def initialize
      packages       = Database.instance.packages(nil)

      @summary_content = <<EOF
<table class="table-striped table-bordered table-condensed">
  <tr><td>パッケージ数</td><td align="right">#{packages.size}</td></tr>
  <tr><td>ファイル数</td><td align="right">#{Database.instance.totalRecords}</td></tr>
</table>
EOF

      @record_content = packages.map do |name|
        "<dt class='result-file'><img src='/images/info.png' /><a href='/info/#{name}'>#{name}</a></dt>"
      end.join("\n")
    end

  end
end

