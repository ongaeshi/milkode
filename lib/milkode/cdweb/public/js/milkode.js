//
// @brief
// @author ongaeshi
// @date   2011/08/24

function escapeHTML(str) {
  return str.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function replace_query_param(url, value)
{
  var url_s = url.split("?");

  if (url_s.length <= 1) {
    if (value.length > 0)
      return url + "?query=" + value;
    else
      return url;
      
  } else {
    var params = url_s[1].split("&");
    var found_query = false;

    for (var i = 0; i < params.length; i++) {
      if (params[i].search(/^query=/) != -1) {
        params[i] = params[i].replace(/^query=.*/, "query=" + value);
        found_query = true;
      }
    }

    if (!found_query)
      params.unshift("query=" + value);

    return url_s[0] + "?" + params.join("&");
  }
}

function topic_path(id)
{
  var url = document.getElementById(id).href;
  url = replace_query_param(url, document.searchform.query.value);
  document.getElementById(id).href = url;
}

function repalce_package_name(url, package_name)
{
  var url_s = url.split("?");
  url = url_s[0].replace(/\/home(\/.*)?/, "/home/" + package_name); // home以下をパッケージ名に置き換え
  return url;
}

function select_package()
{
  var url = document.URL;
  var name = document.getElementById('package').value;

  if (name == '---')
    name = "";

  url = repalce_package_name(url, name);
  url = replace_query_param(url, document.searchform.query.value);
  document.location = url;
}

function select_package_home()
{
  var url = document.URL.replace(/\/$/, "");
  var name = document.getElementById('package_home').value;

  // '---'の時は何もしない
  if (name == '---')
    return;

  document.location = url + "/home/" + name;
}

$(document).ready(function(){
  $("select#package").multiselect({
    multiple: false,
    header: "",
    selectedList: 1,
    height: 450
  }).multiselectfilter();

  $("select#package_home").multiselect({
    multiple: false,
    header: "",
    selectedList: 1,
    height: 350
  }).multiselectfilter();

  $("#updateOk").click(function (e) {
    update_package($("#updateOk").attr("milkode-package-name"));
    return false;
  });

  var match = document.URL.match(/.+(#n\d+)$/);
  if ( match ) {
    $(match[1]).addClass("select-line");
  } else {
    $("#query").select();
  }

  $('#query').click(function(){
    $(this).select();
  });

  $('#shead').change(function(){
    $('#search').click();
  });
});

function update_package(package_name)
{
  // click button
  $("#updateModal .modal-body").html("<h4>更新中... <img src='/images/waiting.gif'/></h4>");
  $("#updateCancel").addClass("hide");
  $("#updateOk").button('loading').off('click');

  // update end
  $.post(
    '/command',
    {
      kind: 'update',
      name: package_name
    },
    function (data) {
      $("#updateModal .modal-body").html("<h4>実行結果</h4>" + "<p>" + data + "</p>");
      $("#updateOk").button('reset').attr("data-dismiss", "modal").text("Close").on('click', function () { location.reload(); });
    }
  );
}

function clippy_text(text, bgcolor)
{
  return '    <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"' + 
    '            width="110"' +
    '            height="14"' +
    '            id="clippy" >' +
    '    <param name="movie" value="/flash/clippy.swf"/>' +
    '    <param name="allowScriptAccess" value="always" />' +
    '    <param name="quality" value="high" />' +
    '    <param name="scale" value="noscale" />' +
    '    <param NAME="FlashVars" value="text=' + text + '">' +
    '    <param name="bgcolor" value="#FFFFFF">' +
    '    <embed src="/flash/clippy.swf"' +
    '           width="110"' +
    '           height="14"' +
    '           name="clippy"' +
    '           quality="high"' +
    '           allowScriptAccess="always"' +
    '           type="application/x-shockwave-flash"' +
    '           pluginspage="http://www.macromedia.com/go/getflashplayer"' +
    '           FlashVars="text=' + text + '"' +
    '           bgcolor="' + bgcolor + '"' +
    '    />' +
    '    </object>';
}

function lineno_setup(path, lineno)
{
  var n_lineno     = "#n" + lineno;

  // scroll reset
  var h    = $('html, body');
  var prev = h.scrollTop();
  window.location.hash = n_lineno;
  h.scrollTop(prev);

  var n_lineno_dom = $(n_lineno);
  var directpath   = path + lineno;

  // select line
  $(".code > pre > *").removeClass("select-line");
  n_lineno_dom.addClass("select-line");

  // copy text button
  $("#lineno-path").html(directpath + clippy_text(directpath, '#FFFFFF'));
  $("#lineno-body").html(n_lineno_dom.html());
  $("#lineno-copyall").html("Lineno + Text" + clippy_text(directpath + " " + escapeHTML(n_lineno_dom.text()), '#F5F5F5'));
}

