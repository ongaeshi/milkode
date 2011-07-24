# -*- coding: utf-8 -*-
require 'optparse'
require 'codestock/cdstk/cdstk'
require 'codestock/common/dbdir.rb'
require 'codestock/cdweb/cli_cdweb'
include CodeStock

module CodeStock
  class CLI_Cdstksub
    def self.setup_init
      options = {:init_default => false}
      
      opt = OptionParser.new("#{File.basename($0)} init")
      opt.on('--default', 'Init db default path, ENV[\'CODESTOCK_DEFAULT_DIR\'] or ~/.codestock.') { options[:init_default] = true }

      return opt, options
    end

    def self.setup_add
      bin = File.basename($0)
      
      opt = OptionParser.new(<<EOF)
#{bin} add package1 [package2 ...]
usage:
  #{bin} add /path/to/dir1
  #{bin} add /path/to/dir2 /path/to/dir3
  #{bin} add /path/is/*
  #{bin} add /path/to/zipfile.zip
  #{bin} add /path/to/addon.xpi
  #{bin} add http://example.com/urlfile.zip
EOF

      opt
    end

    def self.setup_cleanup
      options = {:verbose => false, :force => false}
      
      opt = OptionParser.new("#{File.basename($0)} cleanup")
      opt.on('-f', '--force', 'Force cleanup.') { options[:force] = true }
      opt.on('-v', '--verbose', 'Be verbose.')  { options[:verbose] = true }

      return opt, options
    end

    def self.setup_web
      options = {
        :environment => ENV['RACK_ENV'] || "development",
        :pid         => nil,
        :Port        => 9292,
        :Host        => "0.0.0.0",
        :AccessLog   => [],
        :config      => "config.ru",
        # ----------------------------
        :server      => "thin",
        :LaunchBrowser => true,
        :DbDir => CodeStock::CLI_Cdweb::select_dbdir,
      }
      
      opts = OptionParser.new("#{File.basename($0)} web")
      opts.on('--db DB_DIR', 'Database dir (default : ~/.codestock)') {|v| options[:DbDir] = v }
      opts.on("-o", "--host HOST", "listen on HOST (default: 0.0.0.0)") {|host| options[:Host] = host }
      opts.on('-p', '--port PORT', 'use PORT (default: 9292)') {|v| options[:Port] = v }
      opts.on('-n', '--no-browser', 'No launch browser.') {|v| options[:LaunchBrowser] = false }
      
      # --hostが'-h'を上書きするので、'-h'を再定義してあげる
      opts.on_tail("-h", "-?", "--help", "Show this message") do
        puts opts
        exit
      end
      
      return opts, options
    end
  end
end
