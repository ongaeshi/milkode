# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/06/10

module Milkode
  class DocumentRecord
    attr_accessor :grnrcd
    
    def initialize(grnrcd)
      @grnrcd = grnrcd
    end

    def path
      @grnrcd.path
    end

    def package
      @grnrcd.package
    end

    def restpath
      @grnrcd.restpath
    end

    def content
      @grnrcd.content
    end

    def timestamp
      @grnrcd.timestamp
    end

    def suffix
      @grnrcd.suffix
    end

    def inspect
      "#<Milkode::DocumentRecord:#{[@grnrcd.path, @grnrcd.package, @grnrcd.restpath, @grnrcd.content, @grnrcd.timestamp, @grnrcd.suffix]}>"
    end

    # ---

    def shortpath
      File.join @grnrcd.package, @grnrcd.restpath
    end
  end
end


