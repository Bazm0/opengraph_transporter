#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

 
Rake::TestTask.new do |t|
  t.libs << 'lib/opengraph_transporter'
  t.test_files = FileList['test/lib/opengraph_transporter/*_test.rb']
  t.verbose = true
end
 
task :default => :test
