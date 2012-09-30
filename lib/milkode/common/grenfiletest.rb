# -*- coding: utf-8 -*-

module GrenFileTest
  IGNORE_FILE = /(\A#.*#\Z)|(~\Z)|(\A\.#)|(\.d\Z)|(\.map\Z)|(\.MAP\Z)|(\.xbm\Z)|(\.ppm\Z)|(\.ai\Z)|(\.png\Z)|(\.webarchive\Z)/
  IGNORE_DIR = /(\A\.svn\Z)|(\A\.git\Z)|(\ACVS\Z)/

  def self.ignoreDir?(fpath)
    IGNORE_DIR.match(File.basename(fpath))
  end

  def self.ignoreFile?(fpath)
    IGNORE_FILE.match(File.basename(fpath))
  end

  def self.binary?(fpath)
      s = File.read(fpath, 1024) or return false
      return s.index("\x00")
  end
end
