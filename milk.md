---
layout: layout
title: milk
selected: manual
---
# milkコマンド

-   [データベースの作成](#-1)
-   [パッケージの追加](#-2)
-   [パッケージの検索](#-3)
-   [パッケージの更新](#-4)
-   [カスタムデータベースの作成](#-5)
-   [デフォルトデータベースの切り替え](#-6)
-   [ヘルプコマンド](#-7)

<a name="-1"></a> データベースの作成
-------------------------------------------------------------------------------------

Milkodeのデータベースやパッケージの管理には全て`milk`というコマンドを使います(Windowsでは`milk.bat`)。<br>
まずはデフォルトデータベースを作成しましょう。

<pre>
$ milk init --default
create     : /Users/auser/.milkode/milkode.yaml
create     : /Users/auser/.milkode/db/milkode.db created.
</pre>

Milkodeに登録したソースコードはデータベースと呼ばれる場所に格納されます。<br>
デフォルトデータベースの位置は`~/.milkode`,<br>
もしくは環境変数`MILKODE_DEFAULT_DIR`で指定された値です。

<a name="-2"></a> パッケージの追加
-------------------------------------------------------------------------------------

データベースの作成が終わったらパッケージを登録していきましょう。<br>
試しに*a\_project*というディレクトリを作り、パッケージとして追加します。<br>
パッケージの追加には`milk add`コマンドを使います。

<pre>
$ cd ~/Documents/
$ mkdir a_project
$ echo "aaaaaa" > a_project/a.txt
$ echo "bbbbbb" > a_project/b.txt
$ echo "print 'cccccc'" > a_project/c.rb
$ milk add a_project/
package    : a_project
add_record : /Users/auser/Documents/a_project/a.txt
add_record : /Users/auser/Documents/a_project/b.txt
add_record : /Users/auser/Documents/a_project/c.rb
result     : 1 packages, 3 records, 3 add. (0.21sec)
*milkode*  : 1 packages, 3 records in /Users/auser/.milkode/db/milkode.db.
</pre>

登録されているパッケージは`milk list`コマンドで確認出来ます。

<pre>
$ milk list
a_project
</pre>

インストールしたmilkode本体を登録してみます。

<pre>
# 環境によってgemの位置が変わります (以下は、MacPorts rubyの場合)
$ milk add /opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.9/
.
.
add_record : /opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.9/VERSION
result     : 1 packages, 79 records, 79 add. (0.68sec)
*milkode*  : 2 packages, 82 records in /Users/auser/.milkode/db/milkode.db.
</pre>

httpからの取り込みもサポートしています。**Rubyのソースコード**を取り込んでみましょう。

<pre>
$ milk add http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.zip
download   : http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.zip
extract    : ./packages/http/ruby-1.9.2-p290.zip
package    : ruby-1.9.2-p290
.
.
result     : 1 packages, 3257 records, 3257 add. (1m 1.75s)
*milkode*  : 3 packages, 3339 records in /Users/auser/.milkode/db/milkode.db.
</pre>

`milk list -v`で、パッケージの位置も表示されます。

<pre>
$ milk list -v
a_project         /Users/auser/Documents/a_project
milkode-0.2.9     /opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.9
ruby-1.9.2-p290   /Users/auser/.milkode/packages/zip/ruby-1.9.2-p290
</pre>

管理するパッケージが増えてきたら、キーワードで絞り込むことも出来ます。

<pre>
$ milk list milk
milkode-0.2.9
</pre>

<a name="-3"></a> パッケージの検索
-----------------------------------------------------------------------------------------------

- コマンドラインから検索したい - [gmilk](./gmilk.html)
- ウェブアプリから検索したい - [milk web](./milk-web.html)

<a name="-4"></a> パッケージの更新
-------------------------------------------------------------------------------------

登録したパッケージにファイルを追加したり内容を変更した時は、`milk update`を使うことで更新されます。<br>
まず*a\_project*の内容を変更します。

<pre>
$ mcd a_pro   # もしくは cd /Users/auser/Documents/a_project
/Users/auser/Documents/a_project
$ echo "puts 'cccccc'" > c.rb
$ echo "puts 'dddddd'" > d.rb
</pre>

現在位置にあるパッケージを更新します。

<pre>
$ milk update
package    : a_project
update     : /Users/auser/Documents/a_project/c.rb
add_record : /Users/auser/Documents/a_project/d.rb
result     : 1 packages, 4 records, 1 add, 1 update. (0.01sec)
*milkode*  : 3 packages, 3340 records in /Users/auser/.milkode/db/milkode.db.
</pre>

全てのパッケージを更新したい時は`milk update --all`です。

<pre>
$ milk update --all
package    : a_project
package    : milkode-0.2.9
package    : ruby-1.9.2-p290
result     : 3 packages, 3340 records. (0.74sec)
*milkode*  : 3 packages, 3340 records in /Users/auser/.milkode/db/milkode.db.
</pre>

<a name="-5"></a> カスタムデータベースの作成
-----------------------------------------------------------------------------------------------

**データベースは複数個作ることが出来ます。**<br>
デフォルト以外のデータベースを作る時は引数にディレクトリ名を指定します。

<pre>
$ milk init ~/tmp/milkode_db2  # ディレクトリは一緒に作成します
create     : milkode.yaml
create     : /Users/aurser/tmp/milkode_db2/db/milkode.db created.
</pre>

- カレントディレクトリがMilkodeデータベースの場合、そのデータベースに対して操作を行います。<br>
- カレントディレクトリがデータベースでない場合、デフォルトデータベースに対して操作が行われます。<br>

現在操作可能なデータベースは`milk pwd`で確認可能です。

<pre>
# 現在操作可能なデータベースを確認
$ cd ~/tmp/milkode_db2
$ milk pwd
Not package dir in /Users/aurser/tmp/milkode_db2

# カレントディレクトリがデータベースでない場合、デフォルトデータベースが操作対象となる
$ cd ~
$ milk pwd
Not package dir in /Users/aurser/.milkode
</pre>

<a name="-6"></a> デフォルトデータベースの切り替え
-----------------------------------------------------------------------------------------------------

`milk setdb` でデフォルトデータベースを切り替えることが出来ます。

<pre>
# 'milk sedb'でデフォルトデータベースの切り替え
$ milk setdb ~/tmp/milkode_db2/
Set default db /Users/auser/tmp/milkode_db2.
$ milk pwd
Not package dir in /Users/auser/tmp/milkode_db2.
 
# 'milk list'や'milk grep'の対象も変化する
/Users/auser/tmp/milkode_db2
$ milk list
a_project
$ milk grep -a aaaaaa
Documents/a_project/a.txt:1:aaaaaa
 
# 'milk setdb --default'でデフォルトデータベースを元に戻す
$ milk setdb --default
Reset default db
  remove:      /Users/auser/.milkode_db_dir
  default_db:  /Users/auser/.milkode
$ milk pwd
Not package dir in /Users/auser/.milkode
</pre>

<a name="-7"></a> ヘルプコマンド
-------------------------------------------------------------------------------------

milkには他にも便利なコマンドがたくさん用意されています。

<pre>
$ milk -h
Commands:
  milk add PATH                                        # Add package(s) to milkode
  milk cleanup                                         # Creanup garbage recoeds
  milk dir [package1 package2]                         # Print project root directory
  milk dump                                            # Dump records
  milk fav [package1 package2 ...]                     # Add favorite
  milk files                                           # Display package files
  milk grep                                            # Search projects
  milk help [COMMAND]                                  # Describe available commands or one specific command
  milk ignore [path ...]                               # Ignore a file or directory
  milk info [package]                                  # Display package information
  milk init [db_dir]                                   # Initialize database directory. If db_dir is omitted
  milk list [package1 package2 ...]                    # List package
  milk mcd                                             # Generate `mcd' command
  milk plugins                                         # Display plugins
  milk pwd                                             # Display the current database
  milk rebuild [keyword1 keyword2]                     # Rebuild database
  milk remove keyword_or_path1 [keyword_or_path2 ...]  # Remove package
  milk setdb [dbpath]                                  # Set default db to dbpath
  milk update [keyword1 keyword2 ...]                  # Update database
  milk web                                             # Startup web interface

Options:
  -h, [--help]     # Help message.
      [--version]  # Show version.
</pre>

詳しい使い方は各コマンドのヘルプを見て下さい。

<pre>
$ milk add -h
milk add package1 [package2 ...]
usage:
  milk add /path/to/dir1
  milk add /path/to/dir2 /path/to/dir3
  milk add /path/is/*
  milk add /path/to/zipfile.zip
  milk add /path/to/addon.xpi
  milk add http://example.com/urlfile.zip
</pre>
