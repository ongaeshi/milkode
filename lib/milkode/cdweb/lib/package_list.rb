# -*- coding: utf-8 -*-
#
# @file 
# @brief パッケージ一覧
# @author ongaeshi
# @date   2012/05/25

module Milkode
  class PackageList
    def initialize
    end

    # topページへの表示数の調整は結構大切
    #   view   .. 7
    #   add    .. 5
    #   update .. 5
    #   fav    .. 5
    #
    def top_view
      top_list(%w(export-memo milkode melpa kodeworld junk mruby .emacs.d))
    end

    def top_add
      top_list(%w(kodeworld melpa emacs-deferred mruby rubygems_inner))
    end

    def top_update
      top_list(%w(milkode mruby junk export-memo .emacs.d))
    end

    def top_fav
      top_list(%w(export-memo junk))
    end

    def top_list(list)
      list = list.map {|v|
        "  <li><a href=\"/home/#{v}\">#{v}</a></li>"
      }.join("\n")
      <<EOF
<ul class="unstyled_margin">
#{list}
<li>もっとみる</li>
</ul>
EOF
    end
  end
end
