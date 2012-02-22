require 'helper'
require 'focused_controller/rspec_functional_helper'

module FocusedController
  module RSpecFunctionalHelper
    class FakePostsController
      class Action < ActionController::Base; end
      class Index < Action; end
      class Show < Action; end
    end

    index_spec = RSpec::Core::ExampleGroup.describe FakePostsController::Index do
      include RSpec::Rails::ControllerExampleGroup
      include FocusedController::RSpecFunctionalHelper
    end

    show_spec = nil
    inner_show_spec = nil
    RSpec::Core::ExampleGroup.describe FakePostsController do
      include RSpec::Rails::ControllerExampleGroup
      include FocusedController::RSpecFunctionalHelper

      show_spec = describe(FakePostsController::Show) do
        inner_show_spec = describe('foo') { }
      end
    end

    describe RSpecFunctionalHelper do
      subject { index_spec.new }

      it 'automatically determines the controller class' do
        index_spec.controller_class.must_equal FakePostsController::Index
        show_spec.controller_class.must_equal FakePostsController::Show
        inner_show_spec.controller_class.must_equal FakePostsController::Show
      end

      it 'includes the FocusedController::FunctionalTestHelper' do
        subject.is_a?(FocusedController::FunctionalTestHelper).must_equal true
      end
    end
  end
end
