require File.join(File.dirname(__FILE__), 'test_helper.rb')
require File.join(File.dirname(__FILE__), '../lib/cdweb/cli.rb')
require File.join(File.dirname(__FILE__), '../lib/cdweb/searcher.rb')
require File.join(File.dirname(__FILE__), '../lib/cdweb/viewer.rb')

class TestGrenwebCli < Test::Unit::TestCase
  def test_print_default_output
    # assert_match(/To update this executable/, @stdout)
  end
end
