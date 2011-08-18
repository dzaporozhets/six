require "rubygems"
require "bundler"
Bundler.require(:default, :development)
Dir[File.dirname(__FILE__) + '/support/*.rb'].each {|file| require file }
