---
layout: layout
title: 設定集
---
# 設定集

### 使い方

1. 使いたい設定を表から選び、行ごとクリップボードにコピーします
2. コンテキストメニューから `[FireLink] -> [設定]` を開きます
3. `Import from clipboard` ボタンを押すと設定が追加されます
4. おすすめの設定が見つかったら [twitter/ongaeshi](https://twitter.com/ongaeshi) まで教えて下さい

### Basic

<table>
<tr class="recommended-raw"><td><span>PlainText</span></td><td><span>%text%\n%url%</span></td></tr>
<tr class="recommended-raw"><td><span>Markdown</span></td><td><span>[%text%](%url%)</span></td></tr>
<tr class="recommended-raw"><td><span>Textile</span></td><td><span>"%text%":%url%</span></td></tr>
</table>

### HTML

<table>
<tr class="recommended-raw"><td><span>HTML</span></td><td><span>&lt;a href=&quot;%url%&quot;&gt;%text%&lt;/a&gt;</span></td></tr>
<tr class="recommended-raw"><td><span>HTML(list)</span></td><td><span>&lt;li&gt;&lt;a href=&quot;%url%&quot;&gt;%text%&lt;/a&gt;</span></td></tr>
<tr class="recommended-raw"><td><span>HTML(img)</span></td><td><span>&lt;a href=&quot;%url%&quot;&gt;&lt;img src=&quot;&quot; alt=&quot;%title%&quot;&gt;&lt;/a&gt;</span></td></tr>
<tr class="recommended-raw"><td><span>DTDD</span></td><td><span>&lt;dt&gt;&lt;a href=&quot;%url%&quot;&gt;%title%&lt;/a&gt;&lt;/dt&gt;&lt;dd&gt;%text%&lt;/dd&gt;</span></td></tr>
</table>

### MediaWiki

<table>
<tr class="recommended-raw"><td><span>MediaWiki</span></td><td><span>[%url% %text%]</span></td></tr>
<tr class="recommended-raw"><td><span>MediaWiki(wiki)</span></td><td><span>[[%wikiname%]]</span></td></tr>
<tr class="recommended-raw"><td><span>MediaWiki(wiki,title)</span></td><td><span>[[%wikiname%|%text%]]</span></td></tr>
</table>

### Pukiwiki
<table>
<tr class="recommended-raw"><td><span>Pukiwiki</span></td><td><span>[[%text%&gt;%url%]]</span></td></tr>
<tr class="recommended-raw"><td><span>Pukiwiki(list)</span></td><td><span>- [[%text%&gt;%url%]]</span></td></tr>
</table>

### TiddlyWiki
<table>
<tr class="recommended-raw"><td><span>TiddlyWiki</span></td><td><span>[[%text%|%url%]]</span></td></tr>
<tr class="recommended-raw"><td><span>TiddlyWiki(list)</span></td><td><span>* [[%text%|%url%]]</span></td></tr>
<tr class="recommended-raw"><td><span>TiddlyWiki with DateTime</span></td><td><span>* %DateTime% [[%text%|%url%]]</span></td></tr>
</table>

### etc
<table>
<tr class="recommended-raw"><td><span>Twitter</span></td><td><span>%text% %url%</span></td></tr>
<tr class="recommended-raw"><td><span>Plurl</span></td><td><span>%url% (%text%)</span></td></tr>
<tr class="recommended-raw"><td><span>hatena</span></td><td><span>[%url%:title=%text%]</span></td></tr>
</table>
