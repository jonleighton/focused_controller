require 'bundler/setup'
require 'minitest/spec'
require 'minitest/autorun'
require 'focused_controller'

require 'rspec/core'

# Don't want to actually use RSpec to run our tests
module RSpec::Core::DSL
  remove_method :describe
end

TEST_ROOT = File.expand_path('..', __FILE__)
