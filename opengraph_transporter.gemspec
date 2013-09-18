# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opengraph_transporter/version'

Gem::Specification.new do |gem|
  gem.name          = 'opengraph_transporter'
  gem.version       = OpengraphTransporter::VERSION
  gem.authors       = ['Barry Quigley']
  gem.email         = ['barryquigley@yahoo.com']
  gem.description   = %q{A Ruby library for exporting Facebook Open Graph Translations between Developer Applications.}
  gem.summary       = %q{OpenGraph Transporter provides a quick way of exporting Facebook Open Graph Translations between applications.}
  gem.homepage      = 'http://github.com/Bazm0/opengraph_transporter'
  gem.license       = 'MIT'


  gem.files         = `git ls-files`.split($/)
  gem.executables   = ['opengraph_transporter']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']


  gem.add_dependency 'watir', ['~> 4.0.2']
  gem.add_dependency 'watir-webdriver', ['~> 0.6.4']
  gem.add_dependency 'nokogiri', ['~> 1.6.0']
  gem.add_dependency 'mechanize', ['~> 2.7.1']
  gem.add_dependency 'httpclient', ['~> 2.3.3']
  gem.add_dependency 'json', ['~> 1.8.0']
  gem.add_dependency 'addressable', ['~> 2.2.6']
  gem.add_dependency 'highline', ['~> 1.6.13']
  gem.add_dependency 'console_splash', ['~> 2.0.1']
end
