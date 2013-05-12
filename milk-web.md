---
layout: layout
title: milk web
selected: manual
---
ウェブアプリの起動、検索
-------------------------------------------------------------------------------------------

検索するため、ウェブアプリを起動します。

     $ milk web

ブラウザが開き、webアプリが立ち上がれば成功です。 以後、
[http://127.0.0.1:9292/](http://127.0.0.1:9292/)
にwebアプリが立ち上がっている、という前提で話を進めます。

![](screenshot_01.png)

基本は['require
optparse'](http://127.0.0.1:9292/home/?query=require+optparse)のように調べたい単語を並べていくだけです。
![](screenshot_02.png)

Milkodeは行指向の検索エンジンなので、['def
file'](http://127.0.0.1:9292/home/?query=def+file&shead=directory)でfileという名前のついたメソッドを全て引っ張りだせます。

![](screenshot_03.png)

ファイル名'test'で絞り込みます。['def file
f:test'](http://127.0.0.1:9292/home/?query=def+file+f%3Atest&shead=directory)

![](screenshot_04.png)

ディレクトリ'milkode-0.1.3/lib'以下から検索します。 ['File.extname' in
milkode-0.1.3/lib](http://127.0.0.1:9292/home/milkode-0.1.3/lib?query=File.extname&shead=directory)

![](screenshot_05.png)

拡張子'rdoc'で絞り込みます。['s:rdoc'](http://127.0.0.1:9292/home/milkode-0.1.3?query=s%3Ardoc&shead=directory)

![](screenshot_06.png)

外部からソースを取り込む
---------------------------------------------------------------------------------------------

Milkodeはhttpからの取り込み、zipファイルの展開を自動で行います。試しにRubyのソースコードを取り込んでみましょう。

Ruby-1.9.2-p290 のソースコードを追加

     $ milk add http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.zip
     download   : http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.zip
     extract    : ./packages/http/ruby-1.9.2-p290.zip
     package    : ruby-1.9.2-p290
     .
     .
     result     : 1 packages, 3257 records, 3257 add. (1m 5.76s)

試しに、Enumerable\#each\_with\_indexメソッドを探してみます。['p:ruby
s:c rb\_define\_method
each\_with\_index'](http://127.0.0.1:9292/home/?query=p%3Aruby+s%3Ac+rb_define_method+each_with_index&shead=directory)

![](screenshot_07.png)

見つかりました。
