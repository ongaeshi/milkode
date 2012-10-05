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
       # high priority
       { :name => 'README'        , :filepatterns  => ['README', 'readme']                              },

       # normal priority
       { :name => 'ActionScript'  , :suffixs   => ['as']                                                },
       { :name => 'Autotools'     , :suffixs   => ['am', 'in']                                          },
       { :name => 'AWK'           , :suffixs   => ['awk']                                               },
       { :name => 'Batch File'    , :suffixs   => ['bat']                                               },
       { :name => 'Bundler'       , :filenames => ['Gemfile', 'Gemfile.lock']                           },
       { :name => 'C'             , :suffixs   => ['c', 'h']                                            },
       { :name => 'C#'            , :suffixs   => ['cs']                                                },
       { :name => 'C++'           , :suffixs   => ['cc', 'cpp', 'hpp']                                  },
       { :name => 'CGI'           , :suffixs   => ['cgi']                                               },
       { :name => 'ChangeLog'     , :filenames => ['ChangeLog']                                         },
       { :name => 'Common Lisp'   , :suffixs   => ['cl']                                                },
       { :name => 'CSS'           , :suffixs   => ['css']                                               },
       { :name => 'CSV'           , :suffixs   => ['csv']                                               },
       { :name => 'Diff'          , :suffixs   => ['diff']                                              },
       { :name => 'Emacs Lisp'    , :suffixs   => ['el']                                                },
       { :name => 'Erlang'        , :suffixs   => ['erl']                                               },
       { :name => 'eRuby'         , :suffixs   => ['erb', 'rhtml']                                      },
       { :name => 'gitignore'     , :filenames => ['.gitignore']                                        },
       { :name => 'Haml'          , :suffixs   => ['haml']                                              },
       { :name => 'Haskell'       , :suffixs   => ['hs']                                                },
       { :name => 'HTML'          , :suffixs   => ['html']                                              },
       { :name => 'Java'          , :suffixs   => ['java']                                              },
       { :name => 'JavaScript'    , :suffixs   => ['js']                                                },
       { :name => 'JSON'          , :suffixs   => ['json']                                              },
       { :name => 'Lua'           , :suffixs   => ['lua']                                               },
       { :name => 'Makefile'      , :suffixs   => ['mk']       , :filenames => ['Makefile', 'makefile'] },
       { :name => 'Markdown'      , :suffixs   => ['md', 'markdown']                                    },
       { :name => 'M4'            , :suffixs   => ['m4']                                                },
       { :name => 'Objective-C'   , :suffixs   => ['m', 'mm']                                           },
       { :name => 'PEM'           , :suffixs   => ['pem']                                               },
       { :name => 'Perl'          , :suffixs   => ['pl', 'PL', 'pm', 't']                               },
       { :name => 'POD'           , :suffixs   => ['pod']                                               },
       { :name => 'PHP'           , :suffixs   => ['php']                                               },
       { :name => 'Python'        , :suffixs   => ['py']                                                },
       { :name => 'Rackup'        , :suffixs   => ['ru']                                                },
       { :name => 'Rakefile'      , :suffixs   => ['rake']     , :filenames => ['Rakefile']             },
       { :name => 'RD'            , :suffixs   => ['rd']       , :filepatterns => [/rd.ja\Z/]           },
       { :name => 'RDoc'          , :suffixs   => ['rdoc']                                              },
       { :name => 'Ruby'          , :suffixs   => ['rb']                                                },
       { :name => 'RubyGems'      , :suffixs   => ['gemspec']                                           },
       { :name => 'Scheme'        , :suffixs   => ['scm']                                               },
       { :name => 'sed'           , :suffixs   => ['sed']                                               },
       { :name => 'Shell'         , :suffixs   => ['sh']                                                },
       { :name => 'SVG'           , :suffixs   => ['svg']                                               },
       { :name => 'Tcl'           , :suffixs   => ['tcl']                                               },
       { :name => 'Text'          , :suffixs   => ['txt']                                               },
       { :name => 'XML'           , :suffixs   => ['xml']                                               },
       { :name => 'Yaml'          , :suffixs   => ['yml', 'yaml']                                       },
       # { :name => ''              , :suffixs   => []          , :filenames => [] },
      ]

    UNKNOWN          = 'unknown'
    UNKNOWN_LANGUAGE = {:name => UNKNOWN}
    
    def initialize(filename)
      suffix = File.extname(filename)
      suffix = suffix[1..-1]

      filename = File.basename(filename)

      @lang = LANGUAGES.find {|v|
        is_found = false

        if v[:suffixs]
          is_found = v[:suffixs].include?(suffix)
        end
        
        if !is_found && v[:filenames]
          is_found = v[:filenames].include?(filename)
        end

        if !is_found && v[:filepatterns]
          v[:filepatterns].each do |pattern|
            if filename.match pattern
              is_found = true
              break
            end
          end
        end

        is_found
      }

      @lang ||= UNKNOWN_LANGUAGE
    end

    def name
      @lang[:name]
    end

    def unknown?
      name == UNKNOWN
    end
  end
end

