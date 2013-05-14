---
layout: layout
title: milk web
selected: manual
rootpath: .
---
# milk web

- [ウェブアプリの起動](#start)
- [使い方](#basicsearch)
- [AutoPagerize](#autopagerize)

<a name="start"></a> ウェブアプリの起動
-------------------------------------------------------------------------------------------

`milk web`で起動します。

<pre class="shell">
$ milk web
</pre>

ブラウザが開き、webアプリが立ち上がれば成功です。

<img src="{{page.rootpath}}/images/milkode-web-02.jpg" width="400px"/>

<a name="basicsearch"></a> 使い方
-------------------------------------------------------------------------------------------

<img src="{{page.rootpath}}/images/milkode-web-01.jpg" width="400px"/>

- AND検索: `def test`
- ファイル名'test'で絞り込み: `def file f:test`
- 拡張子'rdoc'で絞り込み: `s:rdoc`

詳しい使い方はウェブアプリ右上の**ヘルプ**をどうぞ。

<a name="autopagerize"></a> AutoPagerize
---------------------------------------------------------------------------------------------

[AutoPagerize](http://autopagerize.net/) に対応しています。<br>
検索結果がたくさんある時に「次へ」ボタンを押さずに継ぎ足し表示してくれるようになります。

