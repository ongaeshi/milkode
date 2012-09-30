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
       { :name => 'ActionScript'  , :suffixs   => ["as"]                                                },
       { :name => 'Bundler'       , :filenames => ["Gemfile", "Gemfile.lock"]                           },
       { :name => 'C'             , :suffixs   => ["c", "h"]                                            },
       { :name => 'C#'            , :suffixs   => ["cs"]                                                },
       { :name => 'C++'           , :suffixs   => ["cpp", "hpp"]                                        },
       { :name => 'Common Lisp'   , :suffixs   => ["cl"]                                                },
       { :name => 'CSS'           , :suffixs   => ["css"]                                               },
       { :name => 'Diff'          , :suffixs   => ["diff"]                                              },
       { :name => 'Emacs Lisp'    , :suffixs   => ["el"]                                                },
       { :name => 'Erlang'        , :suffixs   => ["erl"]                                               },
       { :name => 'eRuby'         , :suffixs   => ["erb"]                                               },
       { :name => 'gitignore'     , :filenames => [".gitignore"]                                        },
       { :name => 'Haml'          , :suffixs   => ["haml"]                                              },
       { :name => 'Haskell'       , :suffixs   => ["hs"]                                                },
       { :name => 'HTML'          , :suffixs   => ["html"]                                              },
       { :name => 'Java'          , :suffixs   => ["java"]                                              },
       { :name => 'JavaScript'    , :suffixs   => ["js"]                                                },
       { :name => 'Lua'           , :suffixs   => ["lua"]                                               },
       { :name => 'Makefile'      , :suffixs   => ["mk"]       , :filenames => ["Makefile", "makefile"] },
       { :name => 'Objective-C'   , :suffixs   => ["m", "mm"]                                           },
       { :name => 'Perl'          , :suffixs   => ["pl"]                                                },
       { :name => 'PHP'           , :suffixs   => ["php"]                                               },
       { :name => 'Python'        , :suffixs   => ["py"]                                                },
       { :name => 'Rakefile'      , :filenames => ["Rakefile"]                                          },
       { :name => 'RDoc'          , :suffixs   => ["rdoc"]                                              },
       { :name => 'Ruby'          , :suffixs   => ["rb"]                                                },
       { :name => 'RubyGems'      , :suffixs   => ["gemspec"]                                           },
       { :name => 'Scala'         , :suffixs   => ["scm"]                                               },
       { :name => 'Text'          , :suffixs   => ["txt"]                                               },
       { :name => 'Yaml'          , :suffixs   => ["yml", "yaml"]                                       },
       # { :name => ''              , :suffixs   => []          , :filenames => [] },
      ]

    UNKNOWN          = 'unknown'
    UNKNOWN_LANGUAGE = {:name => UNKNOWN}
    
    def initialize(filename)
      suffix = File.extname(filename)
      suffix = suffix[1..-1]

      @lang = LANGUAGES.find {|v|
        is_found = false

        if v[:suffixs]
          is_found = v[:suffixs].include?(suffix)
        end
        
        if v[:filenames]
          is_found = v[:filenames].include?(filename)
        end

        is_found
      }

      @lang ||= UNKNOWN_LANGUAGE
    end

    def name
      @lang[:name]
    end

    def <=>(rhs)
    end
  end
end

