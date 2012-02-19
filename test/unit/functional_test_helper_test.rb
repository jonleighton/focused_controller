require 'helper'
require 'action_controller/test_case'

module FocusedController
  module FunctionalTestHelper
    class FakeTestCase
    end

    class FakePostsController
      class Index; end
      class Show; end

      class TestCase < ActionController::TestCase
        include FocusedController::FunctionalTestHelper
      end

      class IndexTest < TestCase
      end

      class ShowTest < TestCase
      end
    end

    describe FunctionalTestHelper do
      subject { FakePostsController::IndexTest.new(nil) }

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
        subject.last_process.must_equal ['run', :foo, :bar, :baz, 'GET']

        subject.post :foo, :bar, :baz
        subject.last_process.must_equal ['run', :foo, :bar, :baz, 'POST']

        subject.put :foo, :bar, :baz
        subject.last_process.must_equal ['run', :foo, :bar, :baz, 'PUT']

        subject.delete :foo, :bar, :baz
        subject.last_process.must_equal ['run', :foo, :bar, :baz, 'DELETE']

        subject.head :foo, :bar, :baz
        subject.last_process.must_equal ['run', :foo, :bar, :baz, 'HEAD']
      end
    end
  end
end
