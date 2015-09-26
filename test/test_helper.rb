ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'minitest/capybara'
require 'minitest/autorun'
require 'rack/test'

require File.expand_path '../../my_app.rb', __FILE__
Dir[File.join(".", "lib/*.rb")].each do |f|
  require f
end
