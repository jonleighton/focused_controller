require 'bundler/setup'
require 'test/unit/testcase'
require 'active_support/test_case'
require 'minitest/spec'
require 'minitest/autorun'
require 'focused_controller'
require 'pathname'
require 'ostruct'
require 'rspec/core'

TEST_ROOT = File.expand_path('..', __FILE__)

# Don't want to actually use RSpec to run our tests
module RSpec::Core::DSL
  remove_method :describe
end

# Annoying monkey-patches. "require 'rspec/rails'" pulls in 'capybara/rails', if it
# can, and capybara/rails assumes there is a full rails env present. So this is a
# hack to make it not fail.
module Rails
  def self.version
    '3.0'
  end

  def self.root
    Pathname.new('')
  end

  def self.application
    OpenStruct.new(:env_config => {})
  end
end
