require 'focused_controller/test_helper'
require 'focused_controller/rspec_controller_class'
require 'rspec/rails'

module FocusedController
  module RSpecHelper
    def self.append_features(base)
      base.class_eval do
        # This must get included higher in the ancestor chain than
        # this module so that inheritance works as desired
        include FocusedController::TestHelper
        extend FocusedController::RSpecControllerClass

        include RSpec::Rails::RailsExampleGroup
        include RSpec::Rails::Matchers::RedirectTo
        include RSpec::Rails::Matchers::RenderTemplate

        subject { controller }
      end

      super
    end
  end
end
