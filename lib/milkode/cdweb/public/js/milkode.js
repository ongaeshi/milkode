//
// @brief
// @author ongaeshi
// @date   2011/08/24

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
});

function update_package(path)
{
  if (window.confirm("Update " + path + "?")) {
    $.post(
      '/command',
      {
        kind: 'update',
        path: path
      },
      function (data) {
        alert(data);
      }
    );
  }
}