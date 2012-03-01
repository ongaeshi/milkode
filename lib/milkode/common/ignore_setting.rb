# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/03/02

class IgnoreSetting
  attr_reader :path
  attr_reader :ignores
  
  def initialize(path, ignores)
    @path = path
    @ignores = ignores
  end
end
