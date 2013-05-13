---
layout: layout
title: エディタから使う
selected: manual
rootpath: .
---
はじめに
---------------------------------------------------------------------------

*gmilk*コマンドはエディタと連携することでさらにその効果を発揮します。
みなさんのお気に入りのエディタを*gmilk*と連携させて下さい。
使えたエディタはこのページに追記してもらえると嬉しいです。

Emacs
-----------------------------------------------------------------------------

*M-x grep* の時に *gmilk* コマンドを使うようにします。

.emacs (or .emacs.d/init.el)

     ; grepをキーバインド
     (global-set-key "\M-g" 'grep)
     (setq grep-command "gmilk ")
     (setq grep-use-null-device nil)
     
     ;grep検索で次の検索結果へ移動
     (global-set-key "\M-o" 'next-error)

*M-g*で検索出来ます。 *M-o*を押すたびに次の検索結果に移動します。

![](Gmilk%20emacs.png)

Sublime Text 2
-----------------------------------------------------------------------------------------------

**@tsurushuu**さんがプラグインを作られています。

[Sublime Text 2からmilkodeのgmilkコマンドを使う -
tsurushuuの日記](http://d.hatena.ne.jp/tsurushuu/20111225/1324800648)
