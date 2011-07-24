# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2011/07/16

module Milkode
  JS_SHORT_CODE = <<EOF
console.dir_s = function (object, msg) {
  var disp_properties  = function (properties, indent, out) {
EOF

  JS_SHORT_HTML = <<EOF
<table class="CodeRay"><tr>
  <td class="line_numbers" title="click to toggle" onclick="with (this.firstChild.style) { display = (display == '') ? 'none' : '' }"><pre>1<tt>
</tt>2<tt>
</tt></pre></td>
  <td class="code"><pre ondblclick="with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }"><span id="1">console.<span class="fu">dir_s</span> = <span class="kw">function</span> (object, msg) {</span><tt>
</tt><span id="2">  <span class="kw">var</span> <span class="fu">disp_properties</span>  = <span class="kw">function</span> (properties, indent, out) {</span><tt>
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
</tt>10<tt>
</tt>11<tt>
</tt>12<tt>
</tt>13<tt>
</tt>14<tt>
</tt>15<tt>
</tt>16<tt>
</tt>17<tt>
</tt>18<tt>
</tt></pre></td>
  <td class="code"><pre ondblclick="with (this.style) { overflow = (overflow == 'auto' || overflow == '') ? 'visible' : 'auto' }"><span id="1">console.<span class="fu">dir_s</span> = <span class="kw">function</span> (object, msg) {</span><tt>
</tt><span id="2">  <span class="kw">var</span> <span class="fu">disp_properties</span>  = <span class="kw">function</span> (properties, indent, out) {</span><tt>
</tt><span id="3">    <span class="kw">for</span> (<span class="kw">var</span> i = <span class="i">0</span>; i &lt; properties.length; ++i) {</span><tt>
</tt><span id="4">      <span class="kw">var</span> name = properties[i][<span class="i">0</span>], value = properties[i][<span class="i">1</span>];</span><tt>
</tt><span id="5"></span><tt>
</tt><span id="6">      <span class="kw">if</span> (<span class="kw">typeof</span> value == <span class="s"><span class="dl">&quot;</span><span class="k">string</span><span class="dl">&quot;</span></span>)</span><tt>
</tt><span id="7">        value = <span class="s"><span class="dl">'</span><span class="k">&quot;</span><span class="dl">'</span></span> + value + <span class="s"><span class="dl">'</span><span class="k">&quot;</span><span class="dl">'</span></span>;</span><tt>
</tt><span id="8"></span><tt>
</tt><span id="9">      out.push(indent + name + <span class="s"><span class="dl">&quot;</span><span class="k">: </span><span class="dl">&quot;</span></span> + value);</span><tt>
</tt><span id="10">    }</span><tt>
</tt><span id="11">  };</span><tt>
</tt><span id="12">  </span><tt>
</tt><span id="13">  <span class="kw">var</span> <span class="fu">disp_funcs</span>  = <span class="kw">function</span> (funcs, indent, out) {</span><tt>
</tt><span id="14">    <span class="kw">for</span> (<span class="kw">var</span> i = <span class="i">0</span>; i &lt; funcs.length; ++i) {</span><tt>
</tt><span id="15">      <span class="kw">var</span> name = funcs[i][<span class="i">0</span>], value = funcs[i][<span class="i">1</span>];</span><tt>
</tt><span id="16">      out.push(indent + name + <span class="s"><span class="dl">&quot;</span><span class="k">()</span><span class="dl">&quot;</span></span>);</span><tt>
</tt><span id="17">    }</span><tt>
</tt><span id="18">  };</span><tt>
</tt></pre></td>
</tr></table>
EOF

end


