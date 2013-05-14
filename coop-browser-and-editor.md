---
layout: layout
title: ブラウザとエディタの連携
selected: manual
rootpath: .
---
# ブラウザとエディタの連携

<img src="{{page.rootpath}}/images/milk-web-03.gif" />

個人的には手放せません。

- [milk web](./milk-web.html)を使ってブラウザからソースコードを検索
- 目的の関数を見つけたら、ジャンプしたい行をクリックしてマークを付ける
- エディタ(Emacs)に移動して `M-x` `milkode:jump-from-browser` を実行
- **ブラウザで見ていたファイルが開かれる**ので、そのまま編集開始

昔から良くある「emacsclient等を使った通信」ではなく、ファイルの実体を開けるのがいい所です。

## インストール
基本セットとして以下のものが必要です。

- Milkode (ソースコード検索)
- Firefox (ブラウザー)
- Emacs (エディタ)

続いてプラグインをインストールします。

- [MozRepl](https://addons.mozilla.org/ja/firefox/addon/mozrepl/) (Firefoxアドオン、EmacsとFirefoxの通信に必要)
- [moz.el](https://github.com/bard/mozrepl/blob/master/chrome/content/moz.el) (Emacsプラグイン、Emacs側の通信)
- [milkode.el](https://github.com/ongaeshi/emacs-milkode) (Emacsプラグイン、Milkodeとの連携に必要)

## Firefoxの設定

1. [アドオンマネージャー]からMozReplをインストールします
1. [ツール] → [MozRepl] -> [Activate on Startup] のチェックをONに

## Emacsの設定

1. moz.el と milkode.el をロードパスの通った場所に置きます。
1. `.emacs.d/init.el`に以下を追記します。

<pre>
(require 'moz)
(require 'milkode)
</pre>

## 使い方
1. Milkodeを使ってブラウザで検索
1. 書き換えたいファイルが見つかったら行をクリックしてマーク
1. ブラウザでそのページを開いたままEmacsに移動
1. `M-x` `milkode:jump-from-browser` を実行

ブラウザで見ているファイルがエディタで開ければ成功です！

## 原理の説明
- ブラウザが今開いているURLを取得する
- URL(`http://xxx/home/proj/to/file#n5`) → Milkodeパス(`/proj/to/file:5`)に変換
- Milkodeパスからファイルの実体パスを取得し、エディタで開く

説明すると3行ですが複数のツールの連携によって実現されています。
