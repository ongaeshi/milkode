---
layout: layout
title: エディタから使う
selected: manual
rootpath: .
---
# エディタから使う

- [はじめに](#init)
- [Emacs(1) - milkode.el](#milkode-el)
- [Emacs(2) - M-x grep](#emacs-grep)
- [Sublime Text 2](#sublime-text-2)

はじめに
---------------------------------------------------------------------------

[gmilkコマンド](./gmilk.html)はエディタと連携させることが出来ます。

お気に入りのエディタとの連携プラグインを書いた方がいましたら[作者](https://twitter.com/ongaeshi)までお知らせ下さい。

Emacs(1) - milkode.el
-----------------------------------------------------------------------------

おすすめ

[ongaeshi/emacs-milkode · GitHub](https://github.com/ongaeshi/emacs-milkode)

Emacs(2) - M-x grep
-----------------------------------------------------------------------------

*M-x grep* の時に *gmilk* コマンドを使うようにします。

**.emacs.d/init.el**
<pre>
; grepをキーバインド
(global-set-key "\M-g" 'grep)
(setq grep-command "gmilk ")
(setq grep-use-null-device nil)
     
;grep検索で次の検索結果へ移動
(global-set-key "\M-o" 'next-error)
</pre>

*M-g*で検索出来ます。 *M-o*を押すたびに次の検索結果に移動します。

Sublime Text 2
-----------------------------------------------------------------------------------------------

**@tsurushuu**さんがプラグインを作られています。

[Sublime Text 2からmilkodeのgmilkコマンドを使う -
tsurushuuの日記](http://d.hatena.ne.jp/tsurushuu/20111225/1324800648)
