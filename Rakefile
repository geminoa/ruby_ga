# -*- encoding: utf-8 -*-

$:.unshift File.dirname(__FILE__)

require "rubygems"

task :default => "test_all"

task :test_all do
  tests = Dir.glob("./test/*")
  tests.each do |f|
    sh "ruby #{f}"
  end
end

task :clean_dat do
  sh "rm -rf try/dat/*"
end
