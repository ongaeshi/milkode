module Milkode
  FILES = <<EOF
/Users/ongaeshi/Documents/milkode/Rakefile
/Users/ongaeshi/Documents/milkode/lib/milkode/cdweb/app.rb
/Users/ongaeshi/Documents/milkode/lib/milkode/cdweb/cli_cdweb.rb
/Users/ongaeshi/Documents/milkode/lib/milkode/cdweb/lib/coderay_html2.rb
/Users/ongaeshi/Documents/milkode/lib/milkode/cdweb/lib/coderay_php_utf8.rb
/Users/ongaeshi/Documents/milkode/lib/milkode/cdweb/lib/database.rb
/Users/ongaeshi/Documents/milkode/lib/milkode/cdweb/public/js/jquery-1.7.2.min.js
/Users/ongaeshi/Documents/milkode/lib/milkode/grep/cli_grep.rb
/Users/ongaeshi/Documents/milkode/test/file_test_utils.rb
/Users/ongaeshi/Documents/milkode/test/test_cdstk_command.rb
/Users/ongaeshi/Documents/milkode/test/test_cdweb_app.rb
/Users/ongaeshi/Documents/milkode/test/test_cli.rb
/Users/ongaeshi/Documents/milkode/test/test_cli_grep.rb
/Users/ongaeshi/Documents/milkode/test/test_database.rb
/Users/ongaeshi/Documents/milkode/test/test_document_record.rb
/Users/ongaeshi/Documents/milkode/test/test_document_table.rb
/Users/ongaeshi/Documents/milkode/test/test_gren_util.rb
/Users/ongaeshi/Documents/milkode/test/test_groonga_database.rb
/Users/ongaeshi/Documents/milkode/test/test_package_table.rb
/Users/ongaeshi/Documents/milkode/test/test_string_snip.rb
/Users/ongaeshi/Documents/milkode/test/test_updater.rb
/Users/ongaeshi/Documents/milkode/test/test_yaml_file_wrapper.rb
EOF
  
  class DummyRecord
    attr_reader :path
    attr_reader :content

    def self.dummy_records
      records = []
      FILES.split.map do |path|
        records << DummyRecord.new(path)
      end
      records
    end

    def initialize(path)
      @path = path
      @content = File.read(@path)
    end
  end
end
