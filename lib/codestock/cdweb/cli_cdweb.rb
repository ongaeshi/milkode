# -*- coding: utf-8 -*-
require 'rubygems'
require 'rack'
require 'launchy'
require 'optparse'
require 'codestock/cdweb/lib/database'

module Rack
  class Server
    def start
      if options[:warn]
        $-w = true
      end

      if includes = options[:include]
        $LOAD_PATH.unshift(*includes)
      end

      if library = options[:require]
        require library
      end

      if options[:debug]
        $DEBUG = true
        require 'pp'
        p options[:server]
        pp wrapped_app
        pp app
      end

      # Touch the wrapped app, so that the config.ru is loaded before
      # daemonization (i.e. before chdir, etc).
      wrapped_app

      daemonize_app if options[:daemonize]
      write_pid if options[:pid]

      trap(:INT) do
        if server.respond_to?(:shutdown)
          server.shutdown
        else
          exit
        end
      end

      server.run wrapped_app, options do
        if (options[:LaunchBrowser])
          host = options[:Host] || options[:BindAddress] # options[:BindAddress] for WEBrick
          Launchy.open("http://#{host}:#{options[:Port]}")
        end
      end
    end
  end
end

module CodeStock
  class CLI_Cdweb
    def self.execute(stdout, argv)
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
        :DbDir => select_dbdir,
      }

      opts = OptionParser.new("#{File.basename($0)}")
      opts.on('--db DB_DIR', 'Database dir (default : ~/.codestock)') {|v| options[:DbDir] = v }
      opts.on("-o", "--host HOST", "listen on HOST (default: 0.0.0.0)") {|host| options[:Host] = host }
      opts.on('-p', '--port PORT', 'use PORT (default: 9292)') {|v| options[:Port] = v }
      opts.on("-s", "--server SERVER", "serve using SERVER (default : thin)") {|s| options[:server] = s }
      opts.on('-n', '--no-browser', 'No launch browser.') {|v| options[:LaunchBrowser] = false }

      # --hostが'-h'を上書きするので、'-h'を再定義してあげる
      opts.on_tail("-h", "-?", "--help", "Show this message") do
        puts opts
        exit
      end
      
      opts.parse!(argv)
      
      # 実行！！
      execute_with_options(options)
    end
    
    def self.execute_with_options(stdout, options)
      # 使用するデータベースの位置設定
      Database.setup(File.expand_path(options[:DbDir]))

      # サーバースクリプトのある場所へ移動
      FileUtils.cd(File.dirname(__FILE__))

      # Rackサーバー起動
      Rack::Server.start(options)
    end
    

    def self.select_dbdir
      if (dbdir?('.') || !dbdir?(db_default_dir))
        '.'
      else
        db_default_dir
      end
    end
  end
end
