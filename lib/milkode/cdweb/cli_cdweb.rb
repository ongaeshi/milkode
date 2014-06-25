# -*- coding: utf-8 -*-
require 'rubygems'
require 'rack'
require 'launchy'
require 'optparse'
require 'milkode/cdweb/lib/database'

module Milkode
  class CLI_Cdweb
    def self.execute_with_options(stdout, options)
      dbdir = File.expand_path(options[:DbDir])
      
      unless options[:customize]
        # 使用するデータベースの位置設定
        Database.setup(dbdir)

        # サーバースクリプトのある場所へ移動
        FileUtils.cd(File.dirname(__FILE__))

        # Rackサーバー生成
        rack_server = Rack::Server.new(options)

        # 起動URL生成
        launch_url = create_launch_url(options)

        # URL設定
        ENV['MILKODE_RELATIVE_URL'] = File.join('/', options[:url]) if options[:url]

        # Allow "http://127.0.0.1:9292/gomilk"
        ENV['MILKODE_SUPPORT_GOMILK'] = "true" if options[:gomilk]

        # 起動
        rack_server.start do
          # この時点でoptions[:Host]やoptions[:Port]などの値が壊れてしまっているため事前にURLを生成している
          Launchy.open(launch_url) if launch_url
        end
      else
        create_customize_file(dbdir)
      end
    end

    def self.create_launch_url(options)
      if (options[:LaunchBrowser])
        host = options[:Host] || options[:BindAddress] # options[:BindAddress] for WEBrick

        base = "http://#{host}:#{options[:Port]}"

        if options[:url]
          File.join(base, options[:url])
        else
          "http://#{host}:#{options[:Port]}"
        end
      else
        nil
      end
    end

    def self.select_dbdir
      # if (Dbdir.dbdir?('.') || !Dbdir.dbdir?(Dbdir.default_dir))
      if Dbdir.dbdir?('.')
        '.'
      else
        Dbdir.default_dir
      end
    end

    def self.create_customize_file(dbdir)
      fname = File.join(dbdir, "milkweb.yaml")
      
      if File.exist? fname
        puts "Already exist '#{fname}'"
      else
        puts <<EOF
Create '#{fname}'.
  Please customize yaml parameter.
EOF

        File.open(fname, "w") do |f|
          f.write <<EOF
---
:home_title     : "Milkode"
:home_icon      : "/images/MilkodeIcon135.png"
:home_font_size : "100%"

:header_title: "Milkode"
:header_icon : "/images/MilkodeIcon135.png"

:favicon: "/images/favicon.ico"

:display_about_milkode: true
:hide_update_button: false
EOF
        end
      end
    end
  end
end
