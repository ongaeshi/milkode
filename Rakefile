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
  gem.name = "codestock"
  gem.homepage = "http://github.com/ongaeshi/codestock"
  gem.license = "MIT"
  gem.summary = %Q{one-line summary of your gem}
  gem.description = %Q{longer description of your gem}
  gem.email = "ongaeshi0621@gmail.com"
  gem.authors = ["ongaeshi"]

  # Include your dependencies below. Runtime dependencies are required when using your gem,
  gem.add_runtime_dependency 'termcolor','>= 1.2.0'
  gem.add_runtime_dependency 'rroonga','>= 1.0.0'
  gem.add_runtime_dependency 'rack','>=1.2.1'
  gem.add_runtime_dependency 'launchy', '>=0.3.7'

  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'

# groonga関連のテストが通らないため、独自のrake_test_loaderを読み込む
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
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

# task :test do
#   load "test/runner.rb"
# end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "codestock #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
