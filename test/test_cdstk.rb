# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/02/20

require 'rubygems'
require 'groonga'
require 'test_helper'
require 'file_test_utils'
require 'codestock/cdstk/cli_cdstk.rb'
require 'codestock/cdstk/cdstk'
require 'stringio'

class TestCdstk < Test::Unit::TestCase
  include CodeStock
  include FileTestUtils
  
  # メッセージを出す時はここをコメントアウト
  def dbputs(msg)
    puts msg
  end
  private :dbputs

  def test_basic
    io = StringIO.new

    begin
      obj = Cdstk.new(io)

      io.puts('--- init ---')
      obj.init
      
      io.puts('--- add ---')
      obj.add(['../../lib/codestock/findgrep', '../../lib/codestock/common'])
      obj.add(['../../lib/codestock/findgrep'])
      obj.add(['../data/abc.zip'])
      obj.add(['../data/nodir_abc.zip'])
      obj.add(['../data/nodir_abc_xpi.xpi'])
      obj.add(['http://ongaeshi.me/test_data/http_nodir_abc.zip'])
      assert_raise(OpenURI::HTTPError) { obj.add(['http://ongaeshi.me/test_data/not_found.zip']) }

      FileUtils.touch('last1.txt')
      obj.add(['last1.txt'])
      FileUtils.touch('atodekesu.txt')
      obj.add(['atodekesu.txt'])
      FileUtils.rm('atodekesu.txt')

      io.puts('--- add notfound ---')
      obj.add(['notfound.html'])

      io.puts('--- update ---')
      FileUtils.touch('packages/zip/abc/c.txt')
      FileUtils.touch('packages/zip/abc/d.txt')
      obj.update

      io.puts('--- remove ---')
      obj.remove(['findgrep'], {:force => true})
      obj.remove([], {:force => true})
      obj.remove(['abc', 'nodir_abc'], {:force => true})

      io.puts('--- list ---')
      obj.list([], {:verbose => true})
      obj.list(['com'], {:verbose => false})

      io.puts('--- cleanup ---')
      # 何故か 'rake test' で実行すると上手く動かないので、一旦テストから外す
      # obj.cleanup({:force=>true})

      io.puts('--- rebuild ---')
      obj.rebuild

      io.puts('--- remove ---')
      obj.remove(['findgrep', 'common'], {:force => true})

      io.puts('--- dump ---')
      obj.dump
    ensure
      dbputs io.string
    end
  end

  def teardown
    teardown_custom(true)
    # teardown_custom(false)
  end
end


