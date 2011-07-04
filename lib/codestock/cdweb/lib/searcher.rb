# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/xx/xxxx

require 'codestock/cdweb/lib/query'

module CodeStock
  class Searcher
    attr_reader :keyword
    attr_reader :total_records
    attr_reader :elapsed
    
    def initialize(keyword)
      @keyword = keyword
      @query = Query2.new(@keyword)
      @records, @total_records, @elapsed = Database.instance.search(@query.keywords, @query.packages, @query.fpaths, @query.suffixs, calcPage, calcLimit)
    end

    def page_range
      # @todo
      0..20
    end
    
    private
    
    # 1ページに表示する最大レコードを計算
    def calcLimit
      20
#       if @query.keywords.size == 0
#         100
#       else
#         20
#       end
    end
    
    # 現在ページを計算
    def calcPage
      0
#      (@request['page'] || 0).to_i
    end

  end
end



