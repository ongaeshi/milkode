# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/06/11

class Array
  def diff(other)
    self_diff = self.reject {|i| other.include? i}
    other_diff = other.reject {|j| self.include? j}
    
    return [self_diff, other_diff]
  end
end



