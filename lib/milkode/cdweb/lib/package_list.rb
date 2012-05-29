# -*- coding: utf-8 -*-
#
# @file 
# @brief パッケージ一覧
# @author ongaeshi
# @date   2012/05/25

require 'milkode/cdweb/lib/database'

module Milkode
  class PackageList
    def initialize(grndb)
      @grndb = grndb
    end

    # topページへの表示数の調整は結構大切
    #   view   .. 7
    #   add    .. 5
    #   update .. 5
    #   fav    .. 5
    #
    def top_view
      grndb_list("viewtime", 7)
      # top_list(%w(kodeworld melpa emacs-deferred mruby rubygems_inner))
    end

    def top_add
      grndb_list("addtime", 5)
    end

    def top_update
      grndb_list("updatetime", 5)
    end

    def top_fav
      top_list(%w(export-memo junk))
    end

    def grndb_list(column_name, num)
      @grndb.open(Database.dbdir) # 再オープン時にパスを指定しなくて済むように
      a = @grndb.packages.sort(column_name).map {|r| r.name}
      top_list(a[0...num])
    end

    def top_list(list)
      list = list.map {|v|
        "  <li><a href=\"/home/#{v}\">#{v}</a></li>"
      }.join("\n")
      <<EOF
<ul class="unstyled_margin">
#{list}
<li><a href=\"/home">next >></a></li>
</ul>
EOF
    end
  end
end
