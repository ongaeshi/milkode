# -*- coding: utf-8 -*-
#
# @file 
# @brief パッケージ一覧
# @author ongaeshi
# @date   2012/05/25

require 'milkode/cdweb/lib/database'

module Milkode
  class PackageList
    VIEW_NUM   = 7
    ADD_NUM    = 5
    UPDATE_NUM = 5
    FAV_NUM    = 7

    FAVORITE_LIST_NUM = 7
    
    def initialize(grndb, suburl)
      @grndb  = grndb
      @suburl = suburl
    end

    # topページへの表示数の調整は結構大切
    #   view   .. 7
    #   add    .. 5
    #   update .. 5
    #   fav    .. 5
    #
    def top_view
      grndb_list("viewtime", VIEW_NUM)
    end

    def top_add
      grndb_list("addtime", ADD_NUM)
    end

    def top_update
      grndb_list("updatetime", UPDATE_NUM)
    end

    def top_fav
      a = @grndb.packages.favs.map{|r| r.name}
      top_list(a[0...FAV_NUM], 'favtime')
    end

    def favorite_list(params)
      names = @grndb.packages.favs.map{|r| r.name}[0..FAVORITE_LIST_NUM-1]

      list = names.map_with_index {|v, index|
        "<strong><a id='favorite_list_#{index}' href='#{Mkurl.new(@suburl + '/home/' + v, params).inherit_query_shead}' onclick='topic_path(\"favorite_list_#{index}\");'>#{v}</a></strong>"
      }.join("&nbsp;&nbsp;\n")

      <<EOF
#{list}&nbsp;&nbsp;
<a href="#{@suburl}/home?sort=favtime">...</a>
EOF
    end

    # ------------------------------------------------------
    private

    def grndb_list(column_name, num)
      a = @grndb.packages.sort(column_name).map {|r| r.name}
      top_list(a[0...num], column_name)
    end

    def top_list(list, column_name)
      list = list.map {|v|
        "  <li><a href=\"#{@suburl}/home/#{v}\">#{v}</a></li>"
      }.join("\n")
      <<EOF
<ul class="unstyled_margin">
#{list}
<li><a href=\"#{@suburl}/home?sort=#{column_name}">next >></a></li>
</ul>
EOF
    end
  end
end
