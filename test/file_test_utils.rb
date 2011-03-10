# -*- coding: utf-8 -*-
#
# @file
# @brief ファイルテスト用ユーティリティ
# @author ongaeshi
# @date 2011/02/21
#
#
# 以下のことを自動でやってくれます
#
# 1. tmpディレクトリの作成
# 2. tmpディレクトリに移動
# 3. テスト実行
# 4. 元のディレクトリに戻る
# 5. tmpディレクトリの削除
#
# また、以下の関数が使えます
#
# assert_diff_files(file1, file2)
#
# 二つのファイルが等しい場合はテスト成功
# 失敗した場合は二つのファイルのdiffを表示します

require 'pathname'
require 'fileutils'

module FileTestUtils
  def setup
    create_tmp_dir
    FileUtils.cd(@tmp_dir.to_s)
  end

  def assert_diff_files(file1, file2)
    unless (IO.read(file1) == IO.read(file2))
      puts `diff -c #{file1} #{file2}`
      assert_equal true, false
    else
      assert_equal true, true
    end
  end

  def teardown
    teardown_custom(true)
  end

  def teardown_custom(is_remove_dir)
    FileUtils.cd(@prev_dir)
    FileUtils.rm_rf(@tmp_dir.to_s) if (is_remove_dir)
  end

  private

  def create_tmp_dir
    @prev_dir = Dir.pwd
    @tmp_dir = Pathname(File.dirname(__FILE__)) + "tmp"
    FileUtils.rm_rf(@tmp_dir.to_s)
    FileUtils.mkdir_p(@tmp_dir.to_s)
  end
end
