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
    NEWS_ITEM_NUM = 20

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

    def news_items(locale)
      updates = @grndb.packages.sort('updatetime')[0...NEWS_ITEM_NUM].map do |v|
        message = I18n.t(:update_news, {package_name: "<a href=\"#{@suburl}/home/#{v.name}\">#{v.name}</a>", locale: locale})
        
        {
          html: "<div class='news-item'>#{message} <span class='time'>#{news_time(v.updatetime)}</span></div>",
          timestamp: v.updatetime
        }
      end

      adds = @grndb.packages.sort('addtime')[0...NEWS_ITEM_NUM].map do |v|
        message = I18n.t(:add_news, {package_name: "<a href=\"#{@suburl}/home/#{v.name}\">#{v.name}</a>", locale: locale})

        {
          html: "<div class='news-item'>#{message} <span class='time'>#{news_time(v.addtime)}</span></div>",
          timestamp: v.addtime
        }
      end

      items = (updates + adds).sort_by {|item|
        item[:timestamp]
      }.reverse[0...NEWS_ITEM_NUM]
        
      items.map {|item|
        item[:html]
      }.join("\n")
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

    def news_time(timestamp)
      timestamp.strftime("%Y-%m-%d %R")
    end
  end
end
