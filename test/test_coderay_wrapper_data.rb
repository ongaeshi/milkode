# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/16

module CodeStock
  JS_SHORT_CODE = <<EOF
console.dir_s = function (object, msg) {
  var disp_properties  = function (properties, indent, out) {
EOF

  JS_SHORT_HTML = <<EOF
<table class="CodeRay"><tr>
  <td class="line_numbers" title="click to toggle" onclick="with (this.firstChild.style) { display = (display == '') ? 'none' : '' }"><pre>1<tt>
</tt>2<tt>
</tt></pre></td>
  <td class="code"><pre ondblclick="with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }">console.<span class="fu">dir_s</span> = <span class="kw">function</span> (object, msg) {<tt>
</tt>  <span class="kw">var</span> <span class="fu">disp_properties</span>  = <span class="kw">function</span> (properties, indent, out) {<tt>
</tt></pre></td>
</tr></table>
EOF
  
  JS_CODE = <<EOF
console.dir_s = function (object, msg) {
  var disp_properties  = function (properties, indent, out) {
    for (var i = 0; i < properties.length; ++i) {
      var name = properties[i][0], value = properties[i][1];

      if (typeof value == "string")
        value = '"' + value + '"';

      out.push(indent + name + ": " + value);
    }
  };
  
  var disp_funcs  = function (funcs, indent, out) {
    for (var i = 0; i < funcs.length; ++i) {
      var name = funcs[i][0], value = funcs[i][1];
      out.push(indent + name + "()");
    }
  };
EOF

  JS_HTML = <<EOF
<table class="CodeRay"><tr>
  <td class="line_numbers" title="click to toggle" onclick="with (this.firstChild.style) { display = (display == '') ? 'none' : '' }"><pre>1<tt>
</tt>2<tt>
</tt>3<tt>
</tt>4<tt>
</tt>5<tt>
</tt>6<tt>
</tt>7<tt>
</tt>8<tt>
</tt>9<tt>
</tt><strong>10</strong><tt>
</tt>11<tt>
</tt>12<tt>
</tt>13<tt>
</tt>14<tt>
</tt>15<tt>
</tt>16<tt>
</tt>17<tt>
</tt>18<tt>
</tt></pre></td>
  <td class="code"><pre ondblclick="with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }">console.<span class="fu">dir_s</span> = <span class="kw">function</span> (object, msg) {<tt>
</tt>  <span class="kw">var</span> <span class="fu">disp_properties</span>  = <span class="kw">function</span> (properties, indent, out) {<tt>
</tt>    <span class="kw">for</span> (<span class="kw">var</span> i = <span class="i">0</span>; i &lt; properties.length; ++i) {<tt>
</tt>      <span class="kw">var</span> name = properties[i][<span class="i">0</span>], value = properties[i][<span class="i">1</span>];<tt>
</tt><tt>
</tt>      <span class="kw">if</span> (<span class="kw">typeof</span> value == <span class="s"><span class="dl">&quot;</span><span class="k">string</span><span class="dl">&quot;</span></span>)<tt>
</tt>        value = <span class="s"><span class="dl">'</span><span class="k">&quot;</span><span class="dl">'</span></span> + value + <span class="s"><span class="dl">'</span><span class="k">&quot;</span><span class="dl">'</span></span>;<tt>
</tt><tt>
</tt>      out.push(indent + name + <span class="s"><span class="dl">&quot;</span><span class="k">: </span><span class="dl">&quot;</span></span> + value);<tt>
</tt>    }<tt>
</tt>  };<tt>
</tt>  <tt>
</tt>  <span class="kw">var</span> <span class="fu">disp_funcs</span>  = <span class="kw">function</span> (funcs, indent, out) {<tt>
</tt>    <span class="kw">for</span> (<span class="kw">var</span> i = <span class="i">0</span>; i &lt; funcs.length; ++i) {<tt>
</tt>      <span class="kw">var</span> name = funcs[i][<span class="i">0</span>], value = funcs[i][<span class="i">1</span>];<tt>
</tt>      out.push(indent + name + <span class="s"><span class="dl">&quot;</span><span class="k">()</span><span class="dl">&quot;</span></span>);<tt>
</tt>    }<tt>
</tt>  };<tt>
</tt></pre></td>
</tr></table>
EOF

end


