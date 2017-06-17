require "rubygems"
require "bundler"
Bundler.require(:default, :development)
require 'coveralls'
Coveralls.wear!

Dir[File.dirname(__FILE__) + '/support/*.rb'].each {|file| require file }

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
end
