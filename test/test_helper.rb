ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'minitest/autorun'
require 'rack/test'

require File.expand_path '../../my_app.rb', __FILE__
