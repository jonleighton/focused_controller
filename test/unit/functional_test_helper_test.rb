require 'helper'
require 'focused_controller/functional_test_helper'
require 'action_controller'

module FocusedController
  module FunctionalTestHelper
    module FakePostsController
      class Action < ActionController::Base; end
      class Index < Action; end
      class Show < Action; end

      class TestCase < ActionController::TestCase
        include FocusedController::FunctionalTestHelper

        def initialize(method_name = :foo)
          super
        end

        def foo; end
      end

      class IndexTest < TestCase
      end

      class ShowTest < TestCase
      end
    end

    describe FunctionalTestHelper do
      subject { FakePostsController::IndexTest.new }

      it 'automatically determines the controller class' do
        FakePostsController::IndexTest.controller_class.
          must_equal FakePostsController::Index
        FakePostsController::ShowTest.controller_class.
          must_equal FakePostsController::Show
      end

      it "doesn't require using the action name to dispatch the action" do
        subject.singleton_class.class_eval do
          attr_reader :last_process

          def process(*args)
            @last_process = args
          end
        end

        subject.get :foo, :bar, :baz
        subject.last_process.must_equal ['call', :foo, :bar, :baz, 'GET']

        subject.post :foo, :bar, :baz
        subject.last_process.must_equal ['call', :foo, :bar, :baz, 'POST']

        subject.put :foo, :bar, :baz
        subject.last_process.must_equal ['call', :foo, :bar, :baz, 'PUT']

        subject.delete :foo, :bar, :baz
        subject.last_process.must_equal ['call', :foo, :bar, :baz, 'DELETE']

        subject.head :foo, :bar, :baz
        subject.last_process.must_equal ['call', :foo, :bar, :baz, 'HEAD']
      end
    end
  end
end
