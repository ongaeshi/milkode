# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/02/21

module Milkode
  class Package
    def initialize(hash)
      @hash = hash
    end

    def self.create(dir, ignore)
      Package.new({"directory" => dir, "ignore" => ignore})
    end

    def directory
      @hash['directory']
    end

    def ignore
      @hash['ignore']
    end

    def hash
      @hash
    end
  end
end


