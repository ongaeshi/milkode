//
// @brief
// @author ongaeshi
// @date   2011/08/24

function replace_query_param(url, value)
{
  var url_s = url.split("?");

  if (url_s.length <= 1) {
    return url + "?query=" + value;
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

