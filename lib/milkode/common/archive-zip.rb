# -*- coding: utf-8 -*-
#
# @file 
# @brief  archive-zipがRuby1.9.2に対応するまでのパッチ、readbytesが無ければ実装する
# @author ongaeshi
# @date   2011/08/04

begin
  require 'readbytes'
rescue LoadError
  # for Ruby 1.9.2
  class TruncatedDataError<IOError
    def initialize(mesg, data) # :nodoc:
      @data = data
      super(mesg)
    end

    # The read portion of an IO#readbytes attempt.
    attr_reader :data
  end
  
  class IO
    # Reads exactly +n+ bytes.
    #
    # If the data read is nil an EOFError is raised.
    #
    # If the data read is too short a TruncatedDataError is raised and the read
    # data is obtainable via its #data method.
    def readbytes(n)
      str = read(n)
      if str == nil
        raise EOFError, "End of file reached"
      end
      if str.size < n
        raise TruncatedDataError.new("data truncated", str) 
      end
      str
    end
  end
end

require 'archive/zip'
