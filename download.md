---
layout: layout
title: ダウンロード
---
# ダウンロード
[RubyGems](https://rubygems.org/gems/milkode)からインストール出来ます。

- [OSX](#osx)
- [Windows](#windows)
- [Linux](#linux)
- [動作チェック](#validate)

## <a id="osx" /> OSX 
**rbenv**

<pre>
$ gem install milkode
$ rbenv rehash
</pre>

**MacPorts**

<pre>
$ sudo gem install milkode
</pre>

## <a id="windows" /> Windows

**[RubyInstaller + DevKit](http://rubyinstaller.org/downloads/)**

<pre>
$ gem.bat install milkode
</pre>

**ActiveScriptRuby**

<pre>
$ gem.bat install rroonga --platform x86-mingw32
$ gem.bat install milkode
</pre>
 
## <a id="linux" /> Linux

<pre>
$ gem install milkode
</pre>

## <a id="validate" /> 動作チェック
`milk`と`gmilk`というコマンドが使えるようになります。(Windowsならば`milk.bat`, `gmilk.bat`)

<pre>
$ milk
Commands:
  milk add PATH
 .
 .
  
$ gmilk --help
gmilk [option] pattern
gmilk is 'milk grep'.
.
.
</pre>

コマンドの詳しい使い方は[マニュアル](./manual.html)をどうぞ。
