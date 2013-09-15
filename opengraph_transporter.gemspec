# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opengraph_transporter/version'

Gem::Specification.new do |gem|
  gem.name          = "opengraph_transporter"
  gem.version       = OpengraphTransporter::VERSION
  gem.authors       = ["Barry Quigley"]
  gem.email         = ["barryquigley@yahoo.com"]
  gem.description   = %q{Open Graph Translations Exporter.}
  gem.summary       = %q{Transporter provides a quick way of exporting Facebook Open Graph Translations between applications.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = ["opengraph_transporter"]
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]


  gem.add_dependency 'watir'
  gem.add_dependency 'watir-webdriver'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'mechanize'
  gem.add_dependency 'logger'
  gem.add_dependency 'httpclient'
  gem.add_dependency 'json'
  gem.add_dependency "addressable", ["~> 2.2.6"]
  gem.add_dependency('fastercsv') if RUBY_VERSION.to_f < 1.9
  gem.add_dependency "httpclient", ["~> 2.3.3"]
  gem.add_dependency  "highline", ["~> 1.6.13"]
end
