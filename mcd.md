---
layout: layout
title: mcd
selected: manual
rootpath: .
---
# パッケージ間を簡単にディレクトリ移動

-   [mcdについて](#mcd)
-   [インストール](#install)
-   [使い方](#usage)
-   [Emacsのshell-modeでの制約](#emacs-shell-mode)

<a name="mcd"></a> mcdについて
---------------------------------------------------------------------------------

コマンドラインからよく実行するコマンドといえば**cd**(ディレクトリ移動)ではないでしょうか。
**mcd**コマンドを使えば、Milkodeデータベースに登録したパッケージの間を簡単に移動することが出来ます。

<pre class="shell">
<span class="comment"># ディレクトリ移動(パッケージ名を全て打つ必要はない)</span>
$ mcd ruby
/Users/auser/.milkode/packages/zip/ruby-1.9.2-p290

$ cd doc/rake/example/

<span class="comment"># パッケージルートに戻る</span>
$ mcd
/Users/auser/.milkode/packages/zip/ruby-1.9.2-p290
</pre>

<a name="install"></a> インストール
-------------------------------------------------------------------------------

`milk mcd`で表示されたテキストを*.bashrc*等に貼付けて下さい。

- Windows環境の場合は*For Cygwin*以下を貼付けて下さい。

<pre class="shell">
$ milk mcd
<span class="comment"># Copy to '.bashrc'.</span>
mcd() {
    local args="$1 $2 $3 $4 $5 $6 $7 $8 $9"
    local dir=`milk dir --top $args`

    if [ "$dir" = "" ]; then
        echo "fatal: Not found package: $1 $2 $3 $4 $5 $6 $7 $8 $9"
    elif [ "$dir" = "Not registered." ]; then
        echo "fatal: Not a package dir: `pwd`"
    else
        cd $dir
        pwd
    fi
}
<span class="comment"># For Cygwin.</span>
mcd() {
    local args="$1 $2 $3 $4 $5 $6 $7 $8 $9"
    local dir=`milk.bat dir --top $args`

    if [ "$dir" = "" ]; then
        echo "fatal: Not found package: $1 $2 $3 $4 $5 $6 $7 $8 $9"
    elif [ "$dir" = "Not registered." ]; then
        echo "fatal: Not a package dir: `pwd`"
    else
        cd $dir
        pwd
    fi
}
</pre>

コピーしたら`source`してインストール完了です。

<pre class="shell">
$ source ~/.bashrc 
</pre>

<a name="usage"></a> 使い方
---------------------------------------------------------------------------

パッケージ名を引数に指定するとディレクトリ移動します。

<pre class="shell">
$ mcd a_pro
/Users/auser/Documents/a_project
</pre>

引数を複数個渡してパッケージ名を絞り込むことが出来ます。

<pre class="shell">
$ mcd milk 0.2.9 <span class="comment"># milkode-0.2.4 と milkode-0.2.9 が混在している時に便利</span>
/opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.9
</pre>

引数無しで実行することでパッケージルートに移動することが出来ます。

<pre class="shell">
$ pwd
/Users/auser/.milkode/packages/zip/ruby-1.9.2-p290/doc/rake/example
$ mcd
/Users/auser/.milkode/packages/zip/ruby-1.9.2-p290
</pre>

パッケージ外でmcdするとエラーになります。

<pre class="shell">
$ cd ~/
$ mcd 
fatal: Not a package dir: /Users/ongaeshi
</pre>

<a name="emacs-shell-mode"></a> Emacsのshell-modeでの制約
----------------------------------------------------------------------------------------------------------

Emacsのshell-modeでmcdを実行するとカレントディレクトリが追従されないことがあります。<br>
そのような時は`M-x dirs`でリセットしましょう。
