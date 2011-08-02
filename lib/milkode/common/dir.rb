# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/08/03

class Dir
  def self.emptydir?(dir)
    entries = Dir.entries(dir)
    entries == [".", ".."] or entries == ["..", "."]
  end
end

