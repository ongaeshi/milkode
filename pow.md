---
layout: layout
title: Powから使う
selected: manual
rootpath: .
---
# Powから使う

[Pow](http://pow.cx/)にも対応しています。Rubyのインストール先は各環境に置き換えて下さい。

## MacPorts

<pre class="shell">
$ cd ~/.pow/
$ ln -s /opt/local/lib/ruby/gems/1.9/gems/milkode-1.0.0 milkode
$ open http://milkode.dev/
</pre>

## rvm

<pre class="shell">
$ cd ~/.pow/
$ ln -s ~/.rvm/gems/ruby-1.9.3-p392/gems/milkode-1.0.0/lib/milkode/cdweb/ milkode
$ open http://milkode.dev/
</pre>

