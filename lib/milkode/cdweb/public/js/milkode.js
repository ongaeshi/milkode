//
// @brief
// @author ongaeshi
// @date   2011/08/24

function topic_path(id)
{
  url = document.getElementById(id).href;
  url = url.replace(/query=.*?&/, "query=" + document.searchform.query.value + "&");
  document.getElementById(id).href = url;
}
