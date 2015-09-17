require "bundler/setup"

require "rails/all"
require "active_support/all"
require "yaml"

require "focused_controller"
require "active_support/test_case"

require "minitest/autorun"
require "minitest/spec"

module Kernel
  alias minitest_describe describe
end

# Require rspec, but avoid using its 'describe'
require "rspec/core"
RSpec.configure do |config|
  config.expose_dsl_globally = false
end
[singleton_class, Module].each do |mod|
  mod.class_eval { alias describe minitest_describe }
end

TEST_ROOT = File.expand_path('..', __FILE__)

class RailsApplication < Rails::Application
  config.root            = TEST_ROOT + "/app"
  config.secret_key_base = "123"
  config.secret_token    = "123"
end
