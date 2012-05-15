# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler'
# begin
#   Bundler.setup(:default, :development)
# rescue Bundler::BundlerError => e
#   $stderr.puts e.message
#   $stderr.puts "Run `bundle install` to install missing gems"
#   exit e.status_code
# end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "milkode"
  gem.homepage = "http://github.com/ongaeshi/milkode"
  gem.license = "MIT"
  gem.summary = %Q{Line based local source code search engine & grep-command & web-app.}
  gem.description = %Q{Line based local source code search engine & grep-command & web-app.}
  gem.email = "ongaeshi0621@gmail.com"
  gem.authors = ["ongaeshi"]
  # Dependencies move to 'Gemfile'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'

# groonga関連のテストが通らないため、独自のrake_test_loaderを読み込む
$LOAD_PATH.unshift '.'
module Rake
  class TestTask < TaskLib
    def rake_loader # :nodoc:
      find_file('test/rake_test_loader') or
        fail "unable to find rake test loader"
    end
  end
end
 
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/**/test_*.rb']
  test.verbose = true
end

task :test_all do
  puts "--- rvm 1.9.2@milkode ---"
  system('rvm 1.9.2@milkode')
  system('rake test')

  puts "--- rvm system ---"
  system('rvm system')
  system('rake test')
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "milkode #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
