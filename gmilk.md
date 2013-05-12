---
layout: layout
title: gmilk
selected: manual
---
Table of Contents

-   [gmilkについて](#gmilk)
-   [基本の検索](#)
-   [現在位置から検索](#-2)
-   [ファイルパスで絞り込み](#-3)
-   [拡張子で絞り込み](#-4)
-   [find-mode](#findmode)
-   [更新しながら検索](#-5)
-   [全てのパッケージから検索](#-6)
-   [パッケージ名を指定して検索](#-7)
-   [大文字小文字](#-8)
-   [色付け](#-9)
-   [その他のコマンド](#-10)

gmilkについて
-------------------------------------------------------------------------------------

*gmilk*というコマンドを使うとMilkodeデータベースの内容をgrepのようにコマンドラインから検索することが出来ます。なお同様のことが*milk
grep*からも出来ます。

     $ gmilk print ccccc
     a_project/c.rb:1:print 'cccccc'

基本の検索
-----------------------------------------------------------------------------

基本は登録したパッケージ内から実行します。

     $ mcd ruby
     /Users/auser/.milkode/packages/zip/ruby-1.9.2-p290

*gmilk キーワード1 キーワード2
....*でAND検索です。数千や数万オーダーのファイル数が登録されていても1秒位で検索出来ます。

     $ gmilk rb_define_method split
     string.c:7505:    rb_define_method(rb_cString, "split", rb_str_split_m, -1);
     ext/tk/tcltklib.c:10519:    rb_define_method(ip, "_split_tklist", ip_split_tklist, 1);
     ext/bigdecimal/bigdecimal.c:2038:    rb_define_method(rb_cBigDecimal, "split", BigDecimal_split, 0);

キーワードを重ねることで絞り込み検索になります。

     $ gmilk rb_define_method split rb_cString
     string.c:7505:    rb_define_method(rb_cString, "split", rb_str_split_m, -1);

*gmilk*はパッケージ内のどこにいても**パッケージ全体を検索**します。
小さなことですが使ってみると現在位置を意識する必要がなくなり、キーワードだけで目的の箇所を探すことが出来るため、コーディングや文書の作成に集中しやすくなります。

     $ cd doc/rake/example
     $ gmilk rb_define_method split rb_cString
     ../../../string.c:7505:    rb_define_method(rb_cString, "split", rb_str_split_m, -1);

現在位置から検索
-------------------------------------------------------------------------------------

*\<-d
相対パス\>*オプションを指定することで現在位置からの相対パスをを基準として検索することが出来ます。

     # 現在位置(ruby-1.9.2-p290/doc/rake/example)から検索
     $ gmilk -d.
     Rakefile1:3:task :default => [:main]
     Rakefile2:4:task :default => [:main]
      
     # 一つ上(ruby-1.9.2-p290/doc/rake)から検索
     $ gmilk -d.. task default
     ../rakefile.rdoc:216:the with_defaults method in the task body.  Here is the above example
     ../CHANGES:85:* Changed RDoc test task to have no default template. This makes it
     ../CHANGES:195:* Made the RDoc task default to internal (in-process) RDoc formatting.
     ../rational.rdoc:91:named, rake will invoke the task "default".
     ../README:54:  task :default => [:test]
     ../README:64:* A task named "default". This task does nothing by itself, but it has exactly
     ../README:65:  one dependency, namely the "test" task. Invoking the "default" task will
     ../README:69:"default" task in the Rakefile:
     Rakefile1:3:task :default => [:main]
     Rakefile2:4:task :default => [:main]

ファイルパスで絞り込み
-------------------------------------------------------------------------------------------

*\<-f
パス名\>*を指定することで、ファイルパスで検索結果を絞り込むことが出来ます。

     # ディレクトリ階層も表現出来る
     $ gmilk -f /doc/rake/example task default
     doc/rake/example/Rakefile1:3:task :default => [:main]
     doc/rake/example/Rakefile2:4:task :default => [:main]

拡張子で絞り込み
-------------------------------------------------------------------------------------

*\<-s
拡張子\>*を指定することで、拡張子で検索結果を絞り込むことが出来ます。

     # 大量に出る検索結果を
     $ gmilk rb_define_method 
     string.c:7453:    rb_define_method(rb_cString, "initialize", rb_str_init, -1);
     .
     .
     .
     # 拡張子.hで絞り込み
     $ gmilk rb_define_method -s h
     ext/openssl/ossl_pkey.h:137:   rb_define_method(class, #name, ossl_##keytype##_get_##name, 0); \
     ext/openssl/ossl_pkey.h:138:   rb_define_method(class, #name "=", ossl_##keytype##_set_##name, 1);\
     include/ruby/ruby.h:1055:void rb_define_method(VALUE,const char*,VALUE(*)(ANYARGS),int);
     include/ruby/intern.h:170:void rb_define_method_id(VALUE, ID, VALUE (*)(ANYARGS), int);
     ext/openssl/ruby_missing.h:15: rb_define_method(klass, "initialize_copy", func, 1)

複数個指定することも出来ます。

     # .rdoc と .txt で絞り込み
     $ gmilk rubygems -s rdoc -s txt -i
     doc/rubygems/History.txt:7:http://rubygems.org is now the default source for downloading gems.
     .
     .
     doc/rake/release_notes/rake-0.8.7.rdoc:37:The easiest way to get and install rake is via RubyGems ...
     doc/rubygems/LICENSE.txt:1:RubyGems is copyrighted free software by Chad Fowler, Rich Kilmer, Jim

何かを検索する際、目的とするファイルの拡張子が分かっていることは結構多いです。
不要な結果を減らすために拡張子を指定することは有効です。
候補が減ることにより検索も速くなるので、積極的に使うことをおすすめします。

find-mode
------------------------------------------------------------------------------------

キーワードを指定せずに*-d*や*-s*、*-f*だけを指定すると**find-mode**になります。検索条件にマッチしたファイル一覧が表示されます。

     # .hを全て表示
     $ gmilk -s h
     debug.h
     dln.h
     enc/iso_2022_jp.h
     enc/unicode/name2ctype.h
     enc/utf_7.h
     enc/x_emoji.h
     encdb.h
     eval_intern.h
     ext/Setup.atheos
     ext/bigdecimal/bigdecimal.h
     .
     .
     .
     
     # 'README'と'ja'を含むファイルを全て検索
     $ gmilk -f README -f ja
     README.EXT.ja
     README.ja
     doc/pty/README.expect.ja
     doc/pty/README.ja
     ext/readline/README.ja
     sample/drb/README.rd.ja
     

更新しながら検索
-------------------------------------------------------------------------------------

**重要な機能**です。*\<-u\>*を付けるとパッケージを更新(*milk
update*)してから検索を開始します。パッケージ内に修正を加えたら定期的に*-u*を付けましょう。

     ChangeLog:14748:  * KNOWNBUGS.rb, bootstraptest/test_fork.rb: move a fixed test.
     ChangeLog:19504:     test_complexrational.rb: [BUG] in IA-64 architecture
     ChangeLog:29330:   * KNOWNBUGS.rb, bootstraptest/test_method.rb: move fixed test.
     ChangeLog:29435:   * KNOWNBUGS.rb: add a test.  see [ruby-dev:36028]
     ChangeLog:34493:   * KNOWNBUGS.rb, bootstraptest/pending.rb: move a bug (?) to pending.
     ChangeLog:34650:   * KNOWNBUGS.rb, bootstraptest/pending.rb: move pending bug.
     ChangeLog:34657:   * KNOWNBUGS.rb, bootstraptest/test_proc.rb: add/move solved test.
     ChangeLog:34786:   * KNOWNBUGS.rb, bootstraptest/test_method.rb: move solved test.
     ChangeLog:34998:   * KNOWNBUGS.rb, bootstraptest/test*.rb: move solved bugs.
     ChangeLog:35217:   * test_knownbug.rb -> KNOWNBUGS.rb: renamed.
     ChangeLog:78067:   * test/soap/calc/test_calc_cgi.rb: take over $DEBUG to ruby process
     common.mk:432: -$(RUNRUBY) "$(srcdir)/bootstraptest/runner.rb" --ruby="$(PROGRAM)" $(OPTS) $(srcdir)/KNOWNBUGS.rb
      
     # -a が付いていれば全てのパッケージを更新してから検索
     $ gmilk -u -a all test case
     package    : a_project
     package    : milkode-0.2.4.5
     package    : ruby-1.9.2-p290
     result     : 3 packages, 3340 records. (0.33sec)
     *milkode*  : 3 packages, 3340 records in /Users/auser.milkode/db/milkode.db.
      
     ChangeLog:39178:   * test/ruby/test_m17n_comb.rb: use allpairs.rb to reduce test cases.
     ChangeLog:56536:   * common.mk (test-all): separate directory where running test cases
     ChangeLog:80028:     run testcases automatically.
     test/rubygems/test_gem_installer.rb:1:require_relative 'gem_installer_test_case'
     test/rexml/data/test/tests.xml:42:    
     test/rubygems/test_gem_uninstaller.rb:1:require_relative 'gem_installer_test_case'

全てのパッケージから検索
---------------------------------------------------------------------------------------------

*\<-a\>*を付けると全てのパッケージを検索対象に含めます。

     $ gmilk -a dddddd
     ../../../../../../Documents/a_project/d.rb:1:puts 'dddddd'
     sprintf.c:217: *            | with one digit before the decimal point as [-]d.dddddde[+-]dd.
     sprintf.c:222: *        f   | Convert floating point argument as [-]ddd.dddddd,
     test/net/http/test_http.rb:303:    data = 'aaabbb cc ddddddddddd lkjoiu4j3qlkuoa'

検索結果が多すぎる時は*\<-n\>*オプションで表示数を抑制しましょう。

     $ gmilk -a puts -n 5
     ../../../../../../Documents/a_project/c.rb:1:puts 'cccccc'
     ../../../../../../Documents/a_project/d.rb:1:puts 'dddddd'
     ../../../../../../../../opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.4.5/Rakefile:7:#   $stderr.puts e.message
     ../../../../../../../../opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.4.5/Rakefile:8:#   $stderr.puts "Run `bundle install` to install missing gems"
     ../../../../../../../../opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.4.5/Rakefile:63:  puts "--- rvm 1.9.2@milkode ---"

パッケージ名を指定して検索
-----------------------------------------------------------------------------------------------

*\<-p\>*で検索するパッケージを指定することが出来ます。

     $ gmilk -p a_project cccccc
     Documents/a_project/c.rb:1:puts 'cccccc'

パッケージは複数指定出来ます。

     $ gmilk -p a_project -p ruby dddddd
     Documents/a_project/d.rb:1:puts 'dddddd'
     .mikode/packages/zip/ruby-1.9.2-p290/sprintf.c:217: *            | with one digit before the decimal point as [-]d.dddddde[+-]dd.
     .mikode/packages/zip/ruby-1.9.2-p290/sprintf.c:222: *        f   | Convert floating point argument as [-]ddd.dddddd,
     .mikode/packages/zip/ruby-1.9.2-p290/test/net/http/test_http.rb:303:    data = 'aaabbb cc ddddddddddd lkjoiu4j3qlkuoa'

大文字小文字
---------------------------------------------------------------------------------

Comming Soon !!

色付け
---------------------------------------------------------------------------

*\<--color\>*で検索結果を色付けすることが出来ます。

![](Gmilk-color.png)

その他のコマンド
--------------------------------------------------------------------------------------

ヘルプを参考にして下さい。

     $ gmilk -h
     gmilk [option] pattern
         -f, --file-keyword KEYWORD       File path. (Enable multiple call)
         -d, --directory DIR              Start directory. (deafult:".")
         -s, --suffix SUFFIX              Suffix.
         -r, --root                       Search from package root.
         -p, --package PACKAGE            Specify search package.
         -a, --all                        Search all package.
         -n NUM                           Limits the number of match to show.
         -i, --ignore                     Ignore case.
             --color                      Color highlight.
             --no-snip                    There being a long line, it does not snip.
             --cache                      Search only db.
             --verbose                    Set the verbose level of output.
         -u, --update                     With update db.
