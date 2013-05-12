---
layout: layout
title: gmilk
selected: manual
---
Table of Contents

-   [mcdについて](#mcd)
-   [インストール](#)
-   [使い方](#-2)
-   [Emacsのshell-modeでの制約](#Emacsshellmode)

mcdについて
---------------------------------------------------------------------------------

コマンドラインからよく実行するコマンドといえば**cd**(ディレクトリ移動)ではないでしょうか。
**mcd**コマンドを使えば、Milkodeデータベースに登録したパッケージの間を簡単に移動することが出来ます。

     # ディレクトリ移動(パッケージ名を全て打つ必要はない)
     $ mcd ruby
     /Users/auser/.milkode/packages/zip/ruby-1.9.2-p290
     
     # パッケージ内を移動した後・・・
     $ cd doc/rake/example/
     
     # 引数無し実行でパッケージルートに戻れる！
     $ mcd
     /Users/auser/.milkode/packages/zip/ruby-1.9.2-p290

インストール
-------------------------------------------------------------------------------

*milk mcd*で表示されたテキストを*.bashrc*等に貼付けて下さい。

-   Windows環境の場合は*For Cygwin*以下を貼付けて下さい。
-   zsh用は使っていないため作れませんでした・・、作った方がいましたらmcdコマンドに追加しますので是非教えて下さい。

<!-- -->

         if [ "$dir" = "" ]; then
     .
     .
     .
      
     # For Cygwin.
     mcd() {
         local args="$1 $2 $3 $4 $5 $6 $7 $8 $9"
         local dir=`milk.bat dir --top $args`
     .
     .

*.bashrc*

     # history設定
     export HISTSIZE=50000
     export HISTFILESIZE=50000
     
     +# mcd
     +mcd() {
     +    local args="$1 $2 $3 $4 $5 $6 $7 $8 $9"
     +    local dir=`milk dir --top $args`
     + 
     +    if [ "$dir" = "" ]; then
     +.
     +.
     +.

コピーしたら*source \~/.bashrc*してインストールは完了です。

     $ source ~/.bashrc 

使い方
---------------------------------------------------------------------------

パッケージ名を引数に指定するとディレクトリ移動します。

     $ mcd a_pro
     /Users/auser/Documents/a_project

引数を複数個渡してパッケージ名を絞り込むことが出来ます。

     $ mcd milk 0.2.9 # 例えば milkode-0.2.4 と milkode-0.2.9 が存在している場合
     /opt/local/lib/ruby/gems/1.8/gems/milkode-0.2.9

引数無しで実行することでパッケージルートに移動することが出来ます。

     $ mcd ruby
     /Users/auser/.milkode/packages/zip/ruby-1.9.2-p290
     $ cd doc/rake/example
     $ pwd
     /Users/auser/.milkode/packages/zip/ruby-1.9.2-p290/doc/rake/example
     $ mcd
     /Users/auser/.milkode/packages/zip/ruby-1.9.2-p290

パッケージ外でmcdするとエラーになります。

     $ cd ~/
     $ mcd 
     fatal: Not a package dir: /Users/ongaeshi

Emacsのshell-modeでの制約
----------------------------------------------------------------------------------------------------------

Emacsのshell-modeでmcdを実行するとカレントディレクトリが追従されないことがあります。
そのような時は*M-x dirs*でリセットしましょう。
