require 'focused_controller/test_helper'
require 'focused_controller/rspec_controller_class'

begin
  # Requiring specific files rather than just 'rspec/rails' because I don't
  # want to force the configuration that 'rspec/rails' adds on people if they
  # haven't specifically chosen to receive it.
  require 'rspec/rails/matchers'
  require 'rspec/rails/adapters'
  require 'rspec/rails/example/rails_example_group'
rescue LoadError
end

module FocusedController
  module RSpecHelper
    def self.append_features(base)
      base.class_eval do
        # This must get included higher in the ancestor chain than
        # this module so that inheritance works as desired
        include FocusedController::TestHelper
        extend ClassMethods
        subject { controller }
      end

      super
    end

    if defined?(RSpec::Rails)
      include RSpec::Rails::RailsExampleGroup
      include RSpec::Rails::Matchers::RedirectTo
      include RSpec::Rails::Matchers::RenderTemplate
    end

    module ClassMethods
      include FocusedController::RSpecControllerClass
    end
  end
end
