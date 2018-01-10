require "rubygems"
require "bundler"
Bundler.require(:default, :development)
require 'simplecov'
SimpleCov.start

Dir[File.dirname(__FILE__) + '/support/*.rb'].each {|file| require file }
