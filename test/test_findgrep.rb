# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2012/04/15

require 'test_helper'
require 'file_assert'
require 'milkode/findgrep/findgrep'

module FindGrep
  class TestFindGrep < Test::Unit::TestCase
    def test_basic

      # Kconv::NOCONV
      # Kconv::SJIS
      # Kconv::UTF8

      Dir.chdir(File.join(File.dirname(__FILE__))) do
        File.open('data/.gitignore') do |f|
          assert_equal '#*.swp', FindGrep::file2lines(f, Kconv::UTF8)[-1]
        end

        File.open('data/a_project/cdstk.rb') do |f|
          # assert_equal 'end', FindGrep::file2lines(f, Kconv::UTF8)[-1]
          assert_equal 'end', FindGrep::file2lines(f, Kconv::SJIS)[-1]
        end
      end
    end
  end
end



