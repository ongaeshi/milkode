# -*- coding: utf-8 -*-
#
# @file 
# @brief
# @author ongaeshi
# @date   2010/10/21

require 'test_helper'
require 'codestock/cdweb/lib/mkurl'

module CodeStock
  class TestMkurl < Test::Unit::TestCase
    def test_basic
      p1 = {:query => 'test', :shead => 'package', :page => '2'}
      p2 = {:query => 'test', :page => '2'}
      p3 = {:page => '2'}

      assert_equal '/home/foo/bar.hpp?query=test&shead=package', Mkurl.new('/home/foo/bar.hpp', p1).inherit_query_shead
      assert_equal '.?query=test&shead=package', Mkurl.new('.', p1).inherit_query_shead
      assert_equal '/home/foo/bar.hpp?query=test', Mkurl.new('/home/foo/bar.hpp', p2).inherit_query_shead
      assert_equal '/home/foo/bar.hpp', Mkurl.new('/home/foo/bar.hpp', p3).inherit_query_shead

      assert_equal '/home/foo/bar.hpp?shead=package', Mkurl.new('/home/foo/bar.hpp', p1).inherit_shead
      assert_equal '.?shead=package', Mkurl.new('.', p1).inherit_shead
      assert_equal '/home/foo/bar.hpp', Mkurl.new('/home/foo/bar.hpp', p2).inherit_shead
      assert_equal '/home/foo/bar.hpp', Mkurl.new('/home/foo/bar.hpp', p3).inherit_shead
      
    end
  end
end
