# -*- coding: utf-8 -*-
#
# @file 
# @brief  Programming Language Detector
# @author ongaeshi
# @date   2012/09/29

module Milkode
  class PlangDetector
    LANGUAGES =
      [
       { :name => 'ActionScript', :suffixs => ['as']         },
       { :name => 'C',            :suffixs => ['c', 'h']     },
       { :name => 'CSS',          :suffixs => ['css']        },
       { :name => 'C#',           :suffixs => ['cs']         },
       { :name => 'C++',          :suffixs => ['cpp', 'hpp'] },
       { :name => 'Java',         :suffixs => ['java']       },
       { :name => 'JavaScript',   :suffixs => ['js']         },
       { :name => 'Ruby',         :suffixs => ['rb']         },
       { :name => 'Text',         :suffixs => ['txt']        },
      ]

   ETC_LANGUAGE = {:name => 'etc'}
    
    def initialize(filename)
      suffix = File.extname(filename)
      suffix = suffix[1..-1]

      @lang = LANGUAGES.find {|v|
        v[:suffixs].include?(suffix)
      }

      @lang ||= ETC_LANGUAGE
    end

    def name
      @lang[:name]
    end
  end
end

