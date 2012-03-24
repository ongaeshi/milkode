# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/24

module Milkode
  class WebSetting
    DEFAULT_SETTING = {
      :top_title    => "Milkode",
      :top_icon     => "/images/MilkodeIcon135.png",

      :header_title => "Milkode",
      :header_icon  => "/images/MilkodeIcon135.png",

      :display_about_milkode => true
    }

    def self.hash_method(name)
      define_method(name) do
        @data[name]
      end
    end

    def initialize
      @data = DEFAULT_SETTING
    end

    hash_method :top_title
    hash_method :top_icon
    
    hash_method :header_title
    hash_method :header_icon

    def about_milkode
      if (@data[:display_about_milkode])
        ', <a href="http://milkode.ongaeshi.me">milkodeについて</a>'
      else
        ''
      end
    end
  end
end

