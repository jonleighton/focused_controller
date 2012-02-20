require 'action_controller'
require 'action_view'
require 'action_dispatch'
require 'rspec/rails'
require 'focused_controller/functional_test_helper'

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
      def controller_class
        controller = metadata[:example_group][:description_args].first

        if controller.respond_to?(:new)
          controller
        else
          super
        end
      end
    end
  end
end
