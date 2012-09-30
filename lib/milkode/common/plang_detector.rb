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
       { :name => 'ActionScript', :suffixs => ['as']           },
       { :name => 'C'           , :suffixs => ['c', 'h']       },
       { :name => 'CSS'         , :suffixs => ['css']          },
       { :name => 'C#'          , :suffixs => ['cs']           },
       { :name => 'C++'         , :suffixs => ['cpp', 'hpp']   },
       { :name => 'Java'        , :suffixs => ['java']         },
       { :name => 'JavaScript'  , :suffixs => ['js']           },
       { :name => 'Ruby'        , :suffixs => ['rb']           },
       { :name => 'Text'        , :suffixs => ['txt']          },
                                                                
       { :name => 'Common Lisp' , :suffixs => ['cl']           },
       { :name => 'Diff'        , :suffixs => ['diff']         },
       { :name => 'Emacs Lisp'  , :suffixs => ['el']           },
       { :name => 'Erlang'      , :suffixs => ['erl']          },
       { :name => 'Haskell'     , :suffixs => ['hs']           },
       { :name => 'HTML'        , :suffixs => ['html']         },
       { :name => 'Lua'         , :suffixs => ['lua']          },
       { :name => 'Objective-C' , :suffixs => ['m', 'mm']      },
       { :name => 'Perl'        , :suffixs => ['pl']           },
       { :name => 'PHP'         , :suffixs => ['php']          },
       { :name => 'Python'      , :suffixs => ['py']           },
       { :name => 'Scala'       , :suffixs => ['scm']          },
       { :name => 'Yaml'        , :suffixs => ['yml', 'yaml']  },
       { :name => 'RDoc'        , :suffixs => ['rdoc']         },
       { :name => 'Haml'        , :suffixs => ['haml']         },
       { :name => 'eRuby'       , :suffixs => ['erb']          },
       { :name => 'RubyGems'    , :suffixs => ['gemspec']      },

       # { :name => ''     ,  :suffixs => ['']       },



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

