# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2013/05/03

module Milkode
  class FindGrepOption
    Option = Struct.new(:patternsNot,
                        :patternsOr,
                        :directory,
                        :depth,
                        :ignoreCase,
                        :caseSensitive,
                        :colorHighlight,
                        :isSilent,
                        :debugMode,
                        :packages,
                        :strict_packages,
                        :filePatterns,
                        :suffixs,
                        :ignoreFiles,
                        :ignoreDirs,
                        :kcode,
                        :output_kcode,
                        :noSnip,
                        :dbFile,
                        :groongaOnly,
                        :isMatchFile,
                        :dispHtml,
                        :matchCountLimit,
                        :keywords,
                        :gotoline,
                        :expand_path,
                        )

    def self.create_default
      Option.new([],
                 [],
                 ".",
                 -1,
                 false,
                 false,
                 false,
                 false,
                 false,
                 [],
                 [],
                 [],
                 [],
                 [],
                 [],
                 Kconv::UTF8, # Platform.get_shell_kcode,
                 Kconv::UTF8,
                 false,
                 nil,
                 false,
                 false,
                 false,
                 -1,
                 [],
                 -1,
                 false,
                 )
    end
  end
end

