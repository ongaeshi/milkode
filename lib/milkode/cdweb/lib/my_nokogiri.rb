# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/12/02

require 'hpricot'
require 'nokogiri'
require 'milkode/common/util'

module Hpricot
  class Elements
    alias_method :at_css, :search
  end
  
  module Traverse
    alias_method :at_css, :search
  end
end

module Milkode
  class MyNokogiri
    def self.HTML(html)
      if Util::ruby19?
        # Nokogiri::HTML(html, nil, 'UTF-8')
        Nokogiri::HTML(html)
      else
        Hpricot(html)
      end
    end
  end
end


