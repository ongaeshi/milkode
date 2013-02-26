# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/02/17

get '*' do
  @setting = WebSetting.new
  @path    = ''
  haml :error
end



