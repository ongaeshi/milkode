require File.join(File.dirname(__FILE__), "test_helper.rb")
require File.join(File.dirname(__FILE__), "../lib/common/util.rb")
require File.join(File.dirname(__FILE__), "../lib/common/grensnip.rb")

class TestStringSnip < Test::Unit::TestCase
  def setup
  end

  def test_ranges_compound
    ranges = [0..7, 8..232, 121..150, 248..255]
    assert_equal(StringSnip.ranges_compound(ranges), [0..232, 248..255])

    ranges = [10..20, 22..30, 33..40]
    assert_equal(StringSnip.ranges_compound(ranges), [10..20, 22..30, 33..40])

    ranges = [10..30, 20..30, 30..40]
    assert_equal(StringSnip.ranges_compound(ranges), [10..40])
  end
  
  def test_string_snip
    str = "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789|12345678901234567890123456789012345678901234567890123456"

    snipper = StringSnip.new
    snip_str = snipper.snip(str, [0..7, -8..-1])
    assert_equal(snip_str, str)

    snipper = StringSnip.new(64)
    snip_str = snipper.snip(str, [-8..-1, 10..20, 0..7])
    assert_equal(snip_str, "12345678<<snip>>12345678901<<snip>>90123456")
  end
end
