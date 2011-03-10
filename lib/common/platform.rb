# -*- coding: utf-8 -*-
require 'kconv'

# LinuxやBSD等にも対応予定(その場合のエンコードって何が適切なんだろ？EUC?UTF8?)
class Platform
  def self.windows_os?
    RUBY_PLATFORM =~ /mswin(?!ce)|mingw|cygwin|bccwin/
  end

  def self.get_shell_kcode
    if windows_os?
      Kconv::SJIS
    else
      Kconv::UTF8
    end
  end
end
