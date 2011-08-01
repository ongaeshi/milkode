# -*- coding: utf-8 -*-
#
# @file
# @brief ファイルテスト用アサート関数群
# @author ongaeshi
# @date 2011/06/22
#
# 以下の関数が使えます
#
# assert_diff_files(file1, file2)
#
# 二つのファイルが等しい場合はテスト成功
# 失敗した場合は二つのファイルのdiffを表示します
#
# assert_lines(s1, s2)
#
# 文字列を行単位で比較します。
#

def assert_diff_files(file1, file2)
  unless (IO.read(file1) == IO.read(file2))
    puts `diff -c #{file1} #{file2}`
    assert_equal true, false
  else
    assert_equal true, true
  end
end

def assert_lines(s1, s2)
  a1 = s1.split("\n")
  a2 = s2.split("\n")
  
  a1.each_index do |i|
    assert_equal a1[i], a2[i]
  end

  # s1の行数が長い時にエラーが出てしまう

  assert_equal a1.size, a2.size
end

