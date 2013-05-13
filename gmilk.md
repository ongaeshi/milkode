---
layout: layout
title: gmilk
selected: manual
rootpath: .
---
Table of Contents

-   [gmilkについて](#-0)
-   [基本の検索](#-1)
-   [現在位置から検索](#-2)
-   [ファイルパスで絞り込み](#-3)
-   [拡張子で絞り込み](#-4)
-   [find-mode](#-5)
-   [更新しながら検索](#-6)
-   [全てのパッケージから検索](#-7)
-   [パッケージ名を指定して検索](#-8)
-   [大文字小文字](#-9)
-   [色付け](#-10)
-   [その他のコマンド](#-11)

<a name="-0"></a> gmilkについて
-------------------------------------------------------------------------------------

`gmilk`というコマンドを使うとgrepのようにコマンドラインから検索することが出来ます。

<pre class="shell">
$ gmilk print                     <span class="comment"># 'milk grep print' でも同じ</span>
a_project/c.rb:1:print 'cccccc'
</pre>

<a name="-1"></a> 基本の検索
-----------------------------------------------------------------------------

登録したパッケージ内から実行します。

<pre class="shell">
$ cd /path/to/ruby-1.9.2-p290
</pre>

*gmilk キーワード1 キーワード2 ..*でAND検索です。

<pre class="shell">
$ gmilk rb_define_method split
string.c:7505:    rb_define_method(rb_cString, "split", rb_str_split_m, -1);
.
.
</pre>     

パッケージ内のどこにいても**パッケージ全体を検索**します。<br>
小さなことですが使ってみると現在位置を意識する必要がなくなり検索しやすくなります。

<pre class="shell">
$ cd doc/rake/example                      <span class="comment"># 移動しても・・</span>
$ gmilk rb_define_method split rb_cString  <span class="comment"># パッケージ全体を検索出来る！</span>
../../../string.c:7505:    rb_define_method(rb_cString, "split", rb_str_split_m, -1);
</pre>

<a name="-2"></a> 現在位置から検索
-------------------------------------------------------------------------------------

*\<-d 相対パス\>*オプションを指定することで現在位置を基準として検索することが出来ます。

<pre class="shell">
<span class="comment"># 現在位置から検索</span>
$ gmilk -d . test
 
<span class="comment"># 一つ上から検索</span>
$ gmilk -d .. test
</pre>

<a name="-3"></a> ファイルパスで絞り込み
-------------------------------------------------------------------------------------------

*\<-f パス名\>*を指定することでファイルパスで結果を絞り込むことが出来ます。

<pre class="shell">
<span class="comment"># ディレクトリ階層も表現出来る</span>
$ gmilk -f doc/rake/example task default
doc/rake/example/Rakefile1:3:task :default => [:main]
.
</pre>

<a name="-4"></a> 拡張子で絞り込み
-------------------------------------------------------------------------------------

*\<-s 拡張子\>*を指定することで拡張子で絞り込むことが出来ます。

<pre class="shell">
<span class="comment"># 拡張子.hで絞り込み</span>
$ gmilk rb_define_method -s h
ext/openssl/ossl_pkey.h:137:   rb_define_method(class, #name, ossl_##keytype##_get_##name, 0); \
.
</pre>

複数個指定することも出来ます。

<pre class="shell">
<span class="comment"># .rdoc と .txt で絞り込み</span>
$ gmilk rubygems -s rdoc -s txt -i
doc/rubygems/History.txt:7:http://rubygems.org is now the default source for downloading gems.
.
</pre>

何かを検索する際、目的とするファイルの拡張子が分かっていることは結構多いです。<br>
候補が減ることにより検索も速くなるので、積極的に使うことをおすすめします。<br>

<a name="-5"></a> find-mode
------------------------------------------------------------------------------------

キーワードを指定せずに*-d*や*-s*、*-f*だけを指定すると**find-mode**になります。検索条件にマッチしたファイル一覧が表示されます。

<pre class="shell">
<span class="comment"># .cppを全て表示</span>
$ gmilk -s cpp
debug.cpp
.
     
<span class="comment"># 'README'と'ja'を含むファイルを全て検索</span>
$ gmilk -f README -f ja
README.EXT.ja
README.ja
.
</pre>
     
<a name="-6"></a> 更新しながら検索
-------------------------------------------------------------------------------------

**重要な機能**です。*\<-u\>*を付けるとパッケージを更新(`milk update`)してから検索を開始します。<br>
パッケージ内に修正を加えたら定期的に*-u*を付けましょう。

<pre class="shell">
$ gmilk -u test
package    : ruby-1.9.2-p290
ChangeLog:39178:   * test/ruby/test_m17n_comb.rb: use allpairs.rb to reduce test cases.
.
.
</pre>

<a name="-7"></a> 全てのパッケージから検索
---------------------------------------------------------------------------------------------

*\<-a\>*を付けると全てのパッケージを検索対象に含めます。

<pre class="shell">
$ gmilk -a dddddd
../../../../../../Documents/a_project/d.rb:1:puts 'dddddd'
.
.
</pre>

検索結果が多すぎる時は*\<-n\>*オプションで表示数を抑制しましょう。

<pre class="shell">
$ gmilk -a puts -n 2
../../../../../../Documents/a_project/c.rb:1:puts 'cccccc'
../../../../../../Documents/a_project/d.rb:1:puts 'dddddd'
</pre>

<a name="-8"></a> パッケージ名を指定して検索
-----------------------------------------------------------------------------------------------

*\<-p\>*で検索するパッケージを指定することが出来ます。

<pre class="shell">
$ gmilk -p a_project cccccc
</pre>

パッケージは複数指定出来ます。

<pre class="shell">
$ gmilk -p a_project -p ruby dddddd
</pre>

<a name="-9"></a> 大文字小文字の区別
---------------------------------------------------------------------------------

<pre class="shell">
<span class="comment"># 全て小文字なら大文字／小文字を区別しないように</span>
$ gmilk milkode test
sample.txt:10:A Milkode test.
test/milkode_test_work.rb:16:class MilkodeTestWork
test/test_cdstk_command.rb:8:require 'milkode_test_work'
 
<span class="comment"># 大文字小文字混ざりの時は厳密に区別します</span>
$ gmilk Milkode test
sample.txt:10:A Milkode test.
 
<span class="comment"># 小文字を厳密に区別したい時は--case-sensitive(--cs)オプションを使います</span>
$ gmilk milkode test --cs
test/test_cdstk_command.rb:8:require 'milkode_test_work'
</pre>

<a name="-10"></a> 色付け
---------------------------------------------------------------------------

*\<--color\>*で検索結果を色付けすることが出来ます。

![gmilk-color]({{page.rootpath}}/images/gmilk-01.png)

<a name="-11"></a> その他のコマンド
--------------------------------------------------------------------------------------

ヘルプを参考にして下さい。

<pre class="shell">
$ gmilk -h
gmilk [option] pattern
gmilk is 'milk grep'.

Stateful:
    -l,                              Change state 'line'. (Match line words.)
    -k,                              Change state 'keyword'. (Match file-content or file-path.)
    First state is 'line'.
    Example:
      gmilk line1 line2 -k keyword1 keyword2 -l line3 -k keyword3 ...

Gotoline:
    -g,                              Go to line mode.
    Enter a file name and line number. If you omit the line number jumps to the line:1.
    Example:
      gmilk -g database lib 7
      lib/database.rb:7:xxxxxxxxxxxxxxx
      database_lib.rb:7:yyyyyyyyyyyyyyy

      gmilk -g lib/database.rb:7 test/test_database.rb:5
      lib/database.rb:7:xxxxxxxxxxxxxxx
      test/test_database.rb:5:yyyyyyyyy

Normal:
    -a, --all                        Search all package.
    -c, --count                      Disp count num.
        --cache                      Search only db.
        --color                      Color highlight.
        --cs, --case-sensitive       Case sensitivity.
    -d, --directory DIR              Start directory. (deafult:".")
        --db DB_DIR                  Specify dbdir. (Use often with '-a')
    -f, --file-path FILE_PATH        File path. (Enable multiple call)
    -i, --ignore                     Ignore case.
    -n NUM                           Limits the number of match to show.
        --no-snip                    There being a long line, it does not snip.
    -p, --package PACKAGE            Specify search package.
    -r, --root                       Search from package root.
    -s, --suffix SUFFIX              Suffix.
    -u, --update                     With update db.
        --verbose                    Set the verbose level of output.
    -v, --version                    Show this version.
</pre>
