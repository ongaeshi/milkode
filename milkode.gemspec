# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'milkode/version'

Gem::Specification.new do |spec|
  spec.name          = "milkode"
  spec.version       = Milkode::VERSION
  spec.authors       = ["ongaeshi"]
  spec.email         = ["ongaeshi0621@gmail.com"]
  spec.summary       = %q{Milkode is line based local source code search engine.}
  spec.description   = %q{Milkode is line based local source code search engine. It have command line interface and web application. It will accelerate the code reading of your life.}
  spec.homepage      = "https://github.com/ongaeshi/milkode"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'sinatra-reloader'
  spec.add_development_dependency 'test-unit' , '>= 2.5.4'

  spec.add_dependency 'termcolor'   , '>= 1.2.0' , '< 1.2.2'
  spec.add_dependency 'rroonga'     , '>= 1.1.0'
  spec.add_dependency 'rack'        , '>= 1.5.2'
  spec.add_dependency 'sinatra'     , '>= 1.2.6'
  spec.add_dependency 'launchy'     , '>= 0.3.7'
  spec.add_dependency 'coderay'     , '>= 1.0.5'
  spec.add_dependency 'thin'        , '>= 1.2.10', '< 2.0.0'
  spec.add_dependency 'archive-zip' , '>= 0.4.0'
  spec.add_dependency 'haml'        , '>= 3.1.2'
  spec.add_dependency 'sass'        , '>= 3.1.3'
  spec.add_dependency 'thor'        , '>= 0.18.1'
  spec.add_dependency 'i18n'        , '~> 0.6.5'
  spec.add_dependency 'whichr'      , '~> 0.3'
end
