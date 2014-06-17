require 'bundler/setup'
gem 'minitest'
require 'active_support'
require 'minitest/autorun'
require 'test/unit/testcase'
require 'active_support/test_case'
require 'minitest/spec'
require 'minitest/autorun'
require 'focused_controller'
require 'pathname'
require 'ostruct'
require 'rspec/core'
require 'rails/version'

TEST_ROOT = File.expand_path('..', __FILE__)

# Don't want to actually use RSpec to run our tests
module RSpec::Core::DSL
  remove_method :describe
end
