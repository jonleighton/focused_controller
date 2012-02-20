require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'rails/test_unit/railtie'

Bundler.require

module App
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
  end
end

# Check out the awesome database
POSTS = []
