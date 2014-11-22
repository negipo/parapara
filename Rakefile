#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require
require 'yaml'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parapara'

task default: %i(build server)

task :build do
  Parapara::Builder.build
end

task :server do
  puts 'server'
end

task :clean do
  sh 'rm -rf tmp/*'
end
