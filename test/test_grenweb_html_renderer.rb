# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), "test_helper.rb")
require File.join(File.dirname(__FILE__), "../lib/grenweb/html_renderer.rb")

class TestGrenwebHTMLRendeler < Test::Unit::TestCase
  include Grenweb

  def setup
    @rendeler = HTMLRendeler.new('/')
  end

  def test_pagination_line
    assert_equal("<span class='pagination-link'><a href='?page=1'>test</a></span>\n", @rendeler.pagination_link(1, "test"))
  end
  
  def test_search_summary
    assert_equal(@rendeler.search_summary(10, 500, 10..20, 0.00893),
                 <<-EOS)
  <div class='search-summary'>
    <span class="keyword">10</span>の検索結果:
    <span class="total-entries">500</span>件中
    <span class="display-range">10 - 20</span>件（0.00893秒）
  </div>
EOS
  end

  def test_match_strong
    assert_equal(@rendeler.match_strong("This is line.", [nil, nil]), "This is line.")
  end

  def test_search_box
    assert_equal(@rendeler.search_box('test must'), <<-EOF)
<form method="post" action="/::search">
  <p>
    <input name="query" type="text" size="60" value="test must" />
    <input type="submit" value="検索" />
  </p>
</form>
EOF
  end
end
