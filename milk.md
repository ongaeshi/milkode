---
layout: layout
title: milk
selected: manual
rootpath: .
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

<pre class="shell">
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

<pre class="shell">
$ milk add a_project/
package    : a_project
add_record : /Users/auser/Documents/a_project/a.txt
add_record : /Users/auser/Documents/a_project/b.txt
add_record : /Users/auser/Documents/a_project/c.rb
result     : 1 packages, 3 records, 3 add. (0.21sec)
*milkode*  : 1 packages, 3 records in /Users/auser/.milkode/db/milkode.db.
</pre>

インストールしたmilkode本体を登録してみます。

<pre class="shell">
$ milk add /opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.9/ <span class="comment"># 環境によってgemの位置は変わります</span>
</pre>

httpからの取り込みもサポートしています。**Rubyのソースコード**を取り込んでみましょう。

<pre class="shell">
$ milk add http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.zip
</pre>

登録されているパッケージは`milk list`コマンドで確認出来ます。

<pre class="shell">
<span class="comment"># パッケージ一覧を表示。</span>
$ milk list
a_project
milkode-0.2.9
ruby-1.9.2-p290

<span class="comment"># キーワードで絞り込むことも出来ます。</span>
$ milk list milk
milkode-0.2.9

<span class="comment"># `milk list -v`でパッケージ位置も表示。</span>
$ milk list -v milk
milkode-0.2.9     /opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.9
</pre>

<a name="-3"></a> パッケージの検索
-----------------------------------------------------------------------------------------------

好きな方法でどうぞ。

- ウェブアプリから検索したい → [milk web](./milk-web.html)
- コマンドラインから検索したい → [gmilk](./gmilk.html)
- エディタから検索したい → [エディタから使う](./use-from-editor.html)

<a name="-4"></a> パッケージの更新
-------------------------------------------------------------------------------------

パッケージにファイルを追加したり内容を変更した時は、`milk update`を使います。<br>
現在位置にあるパッケージを更新します。

<pre class="shell">
$ milk update
package    : a_project
.
.
</pre>

全てのパッケージを更新したい時は`milk update --all`です。

<pre class="shell">
$ milk update --all
package    : a_project
package    : milkode-0.2.9
.
.
</pre>

<a name="-5"></a> カスタムデータベースの作成
-----------------------------------------------------------------------------------------------

**データベースは複数個作ることが出来ます。**<br>
デフォルト以外のデータベースを作る時は引数にディレクトリ名を指定します。

<pre class="shell">
$ milk init ~/tmp/milkode_db2  <span class="comment"># ディレクトリは一緒に作成します</span>
create     : milkode.yaml
create     : /Users/aurser/tmp/milkode_db2/db/milkode.db created.
</pre>

- カレントディレクトリがMilkodeデータベースの場合、そのデータベースに対して操作を行います。<br>
- カレントディレクトリがデータベースでない場合、デフォルトデータベースに対して操作が行われます。<br>

現在操作可能なデータベースは`milk pwd`で確認可能です。

<pre class="shell">
<span class="comment"># 現在操作可能なデータベースを確認</span>
$ cd ~/tmp/milkode_db2
$ milk pwd
On database in /Users/aurser/tmp/milkode_db2

<span class="comment"># カレントディレクトリがデータベースでない場合、デフォルトデータベースが操作対象となる</span>
$ cd ~
$ milk pwd
On database in /Users/aurser/.milkode
</pre>

<a name="-6"></a> デフォルトデータベースの切り替え
-----------------------------------------------------------------------------------------------------

`milk setdb` でデフォルトデータベースを切り替えることが出来ます。

<pre class="shell">
<span class="comment"># 'milk sedb'でデフォルトデータベースの切り替え</span>
$ milk setdb ~/tmp/milkode_db2/
Set default db /Users/auser/tmp/milkode_db2.
$ milk pwd
Not package dir in /Users/auser/tmp/milkode_db2.
 
<span class="comment"># 'milk list'や'milk grep'の対象も変化する</span>
/Users/auser/tmp/milkode_db2
$ milk list
a_project
$ milk grep -a aaaaaa
Documents/a_project/a.txt:1:aaaaaa
 
<span class="comment"># 'milk setdb --default'でデフォルトデータベースを元に戻す</span>
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

<pre class="shell">
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

<pre class="shell">
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
