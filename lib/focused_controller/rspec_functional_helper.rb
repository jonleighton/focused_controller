require 'action_controller'
require 'action_view'
require 'action_dispatch'
require 'rspec/rails'
require 'focused_controller/functional_test_helper'
require 'focused_controller/rspec_controller_class'

module FocusedController
  module RSpecFunctionalHelper
    def self.append_features(base)
      base.class_eval do
        # This must be included first
        include RSpec::Rails::ControllerExampleGroup
        extend ClassMethods
        include FocusedController::FunctionalTestHelper
      end

      super
    end

    module ClassMethods
      include FocusedController::RSpecControllerClass
    end
  end
end
