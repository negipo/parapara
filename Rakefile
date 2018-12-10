#!/usr/bin/env ruby

require 'bundler/setup'
Bundler.require
require 'yaml'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parapara'

desc '#'
task default: %i(build server)

desc '#'
task :build do
  Parapara::Builder.build
end

desc '#'
task :server do
  Parapara::Server.run!
end

desc '#'
task :cleanup do
  sh 'rm -rf tmp/cache'
  sh 'rm -rf static/converted'
end
