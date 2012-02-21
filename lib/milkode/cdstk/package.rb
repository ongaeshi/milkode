# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/02/21

require 'milkode/common/util'

module Milkode
  class Package
    def self.create(dir, ignore)
      Package.new({"directory" => dir, "ignore" => ignore})
    end

    def initialize(hash)        # from milkode.yaml
      @hash = hash
      normalize
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

    def normalize
      if (Util::platform_win?)
        @hash['directory'] = Util::normalize_filename(directory)
      end
    end

    def migrate
      @hash['ignore'] = [] unless ignore
    end
  end
end


