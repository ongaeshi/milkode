---
layout: layout
title: ダウンロード
---
[RubyGems](https://rubygems.org/gems/milkode)からインストール出来ます。

- [OSX](#osx)
- [Windows](#windows)
- [Linux](#linux)
- [インストールに成功すると](#success)

## <a id="osx"></a> OSX 
**rbenv**

<pre>
$ gem install milkode
$ rbenv rehash
</pre>

**MacPorts**

<pre>
$ sudo gem install milkode
</pre>

## <a id="windows"></a> Windows

**RubyInstaller + DevKit**

<pre>
$ gem.bat install milkode
</pre>

**ActiveScriptRuby**

<pre>
$ gem.bat install rroonga --platform x86-mingw32
$ gem.bat install milkode
</pre>
 
## <a id="linux"></a> Linux

<pre>
$ gem install milkode
</pre>

## <a id="success"></a> インストールに成功すると

`milk`, `gmilk`というコマンドが使えるようになります。(Windowsならば`milk.bat`です。)

各コマンドの詳しい使い方は[マニュアル](./manual.html)をどうぞ。
