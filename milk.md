---
layout: layout
title: milk
selected: manual
---
Table of Contents

-   [デフォルトデータベースの作成](#)
-   [パッケージの追加](#-2)
-   [mcdコマンドのインストール](#mcd)
-   [登録したパッケージ内の検索](#-3)
-   [パッケージの更新](#-4)
-   [カスタムデータベースの作成](#-5)
-   [デフォルトデータベースの切り替え](#-6)
-   [その他のコマンド](#-7)

デフォルトデータベースの作成
-----------------------------------------------------------------------------------------------

Milkodeのデータベースやパッケージの管理には全て*milk*というコマンドを使います(Windowsでは*milk.bat*)。
まずはデフォルトデータベースを作成しましょう。

     $ milk init --default
     create     : /Users/auser/.milkode/milkode.yaml
     create     : /Users/auser/.milkode/db/milkode.db created.

Milkodeに登録したソースコードはデータベースと呼ばれる場所に格納されます。
デフォルトデータベースの位置は*\~/.milkode*,
もしくは環境変数*MILKODE\_DEFAULT\_DIR*で指定された値です。

パッケージの追加
-------------------------------------------------------------------------------------

データベースの作成が終わったらパッケージを登録していきましょう。
試しに*a\_project*というディレクトリを作り、パッケージとして追加します。

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

登録されているパッケージは*milk list*コマンドで確認出来ます。

     $ milk list
     a_project

インストールしたmilkode本体を登録してみます。

     # 環境によってgemの位置が変わります (以下は、MacPorts rubyの場合)
     $ milk add /opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.9/
     .
     .
     add_record : /opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.9/VERSION
     result     : 1 packages, 79 records, 79 add. (0.68sec)
     *milkode*  : 2 packages, 82 records in /Users/auser/.milkode/db/milkode.db.

httpからの取り込みもサポートしています。Rubyのソースコードを取り込んでみます。

     $ milk add http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.zip
     download   : http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.zip
     extract    : ./packages/http/ruby-1.9.2-p290.zip
     package    : ruby-1.9.2-p290
     .
     .
     result     : 1 packages, 3257 records, 3257 add. (1m 1.75s)
     *milkode*  : 3 packages, 3339 records in /Users/auser/.milkode/db/milkode.db.

*milk list -v*で、パッケージの位置も表示されます。

     $ milk list -v
     a_project         /Users/auser/Documents/a_project
     milkode-0.2.9   /opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.9
     ruby-1.9.2-p290   /Users/auser/.milkode/packages/zip/ruby-1.9.2-p290

管理するパッケージが増えてきたら、キーワードで絞り込むことも出来ます。

     $ milk list milk
     milkode-0.2.9

mcdコマンドのインストール
-----------------------------------------------------------------------------------------------

mcdコマンドをインストールすると、パッケージ間を素早く移動することが出来るようになるのでおすすめです。

<パッケージ間を簡単に移動するためのmcdコマンド>

登録したパッケージ内の検索
-----------------------------------------------------------------------------------------------

データベースに登録したパッケージは*milk
grep*コマンドを使って検索することが出来ます。
**-a**は全てのパッケージから、という意味です、**print**と**cccc**両キーワードを含む行を探します。

     $ milk grep -a print ccccc
     a_project/c.rb:1:print 'cccccc'

Rubyのソースコードから**splitメソッドを定義している箇所**を特定してみます。
3339ファイルから検索していますが一瞬です。

     $ milk grep -a rb_define_method split
     ../.milkode/packages/zip/ruby-1.9.2-p290/string.c:7505:    rb_define_method(rb_cString, "split", rb_str_split_m, -1);
     ../.milkode/packages/zip/ruby-1.9.2-p290/ext/tk/tcltklib.c:10519:    rb_define_method(ip, "_split_tklist", ip_split_tklist, 1);
     ../.milkode/packages/zip/ruby-1.9.2-p290/ext/bigdecimal/bigdecimal.c:2038:    rb_define_method(rb_cBigDecimal, "split", BigDecimal_split, 0);

**milk
grep**のさらに詳しい使い方については、<コマンドラインから検索>をどうぞ。

パッケージの更新
-------------------------------------------------------------------------------------

登録したパッケージにファイルを追加したり内容を変更した時は、*milk
update*を使うことで検索対象に含まれるようになります。
まず*a\_project*の内容を変更します。

     $ mcd a_pro   # もしくは cd /Users/auser/Documents/a_project
     /Users/auser/Documents/a_project
     $ echo "puts 'cccccc'" > c.rb
     $ echo "puts 'dddddd'" > d.rb

*milk update*しましょう、現在位置にあるパッケージを更新します。

     $ milk update
     package    : a_project
     update     : /Users/auser/Documents/a_project/c.rb
     add_record : /Users/auser/Documents/a_project/d.rb
     result     : 1 packages, 4 records, 1 add, 1 update. (0.01sec)
     *milkode*  : 3 packages, 3340 records in /Users/auser/.milkode/db/milkode.db.

全てのパッケージを更新したい時は*milk update --all*です。

     $ milk update --all
     package    : a_project
     package    : milkode-0.2.9
     package    : ruby-1.9.2-p290
     result     : 3 packages, 3340 records. (0.74sec)
     *milkode*  : 3 packages, 3340 records in /Users/auser/.milkode/db/milkode.db.

カスタムデータベースの作成
-----------------------------------------------------------------------------------------------

データベースは複数個作ることが出来ます。
デフォルト以外のデータベースを作る時は引数にディレクトリ名を指定します。

     $ milk init ~/tmp/milkode_db2  # ディレクトリは一緒に作成します
     create     : milkode.yaml
     create     : /Users/aurser/tmp/milkode_db2/db/milkode.db created.

カレントディレクトリがMilkodeデータベースの場合、そのデータベースに対して操作を行います。
カレントディレクトリがデータベースでない場合、デフォルトデータベースに対して操作が行われます。
現在操作可能なデータベースは*milk pwd*で確認可能です。

     # 現在操作可能なデータベースを確認
     $ cd ~/tmp/milkode_db2
     $ milk pwd
     /Users/aurser/tmp/milkode_db2

     # milkode_db2 に a_project を追加
     $ milk add ~/Documents/a_project/
     package    : a_project
     add_record : /Users/aurser/Documents/a_project/a.txt
     add_record : /Users/aurser/Documents/a_project/b.txt
     add_record : /Users/aurser/Documents/a_project/c.rb
     add_record : /Users/aurser/Documents/a_project/d.rb
     result     : 1 packages, 4 records, 4 add. (0.15sec)
     *milkode*  : 1 packages, 4 records in /Users/aurser/tmp/milkode_db2/db/milkode.db.

     # 確認
     $ milk list
     a_project

     # カレントディレクトリがデータベースでない場合、デフォルトデータベースが操作対象となる
     $ cd ~
     $ milk pwd
     /Users/aurser/.milkode

デフォルトデータベースの切り替え
-----------------------------------------------------------------------------------------------------

*milk setdb* でデフォルトデータベースを切り替えることが出来ます。

     # 'milk sedb'でデフォルトデータベースの切り替え
     $ milk setdb ~/tmp/milkode_db2/
     Set default db /Users/auser/tmp/milkode_db2.
     # 確認
     $ milk pwd
      
     # 'milk list'や'milk grep'の対象も変化する
     /Users/auser/tmp/milkode_db2
     $ milk list
     a_project
     $ milk grep -a aaaaaa
     Documents/a_project/a.txt:1:aaaaaa
      
     # 'milk setdb --reset'でデフォルトデータベースを元に戻す
     $ milk setdb --reset
     Reset default db
       remove:      /Users/auser/.milkode_db_dir
       default_db:  /Users/auser/.milkode
     # 確認
     $ milk pwd
     /Users/auser/.milkode

その他のコマンド
-------------------------------------------------------------------------------------

milkには他にも便利なコマンドがたくさん用意されています。詳しい使い方は各コマンドのヘルプを見て下さい。

<pre>
The most commonly used milk are:
  add         Add packages.
  cleanup     Cleanup garbage records.
  dir         Disp package dir.
  dump        Dump records.
  grep        Print lines matching a pattern
  init        Init db.
  list        List packages. 
  mcd         Print 'mcd' command.
  pwd         Disp current db.
  rebuild     Rebuild db.
  remove      Remove packages.
  setdb       Set default db. 
  update      Update packages.
  web         Run web-app.

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
