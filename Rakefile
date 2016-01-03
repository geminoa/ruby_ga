# -*- encoding: utf-8 -*-

$:.unshift File.dirname(__FILE__)

require "rubygems"

task :default => "test"

task :test do
  tests = Dir.glob("./test/*")
  tests.each do |f|
    sh "ruby #{f}"
  end
end
