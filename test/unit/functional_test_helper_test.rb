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

      def record_last_process
        subject.singleton_class.class_eval do
          attr_reader :last_process

          def process(action_name, *args)
            if ActionPack::VERSION::MAJOR < 4
              args.unshift args.pop
            end

            @last_process = [action_name, *args]
          end
        end
      end

      it 'automatically determines the controller class' do
        FakePostsController::IndexTest.controller_class.
          must_equal FakePostsController::Index
        FakePostsController::ShowTest.controller_class.
          must_equal FakePostsController::Show
      end

      it "doesn't require using the action name to dispatch the action" do
        record_last_process

        parameters = {:foo => "bar"}
        session = {:baz => "bat"}
        flash = {:quux => "wibble"}

        subject.get parameters, session, flash
        subject.last_process.must_equal ['call', 'GET', parameters, session, flash]

        subject.post parameters, session, flash
        subject.last_process.must_equal ['call', 'POST', parameters, session, flash]

        subject.put parameters, session, flash
        subject.last_process.must_equal ['call', 'PUT', parameters, session, flash]

        subject.delete parameters, session, flash
        subject.last_process.must_equal ['call', 'DELETE', parameters, session, flash]

        subject.head parameters, session, flash
        subject.last_process.must_equal ['call', 'HEAD', parameters, session, flash]
      end

      describe "testing a non-focused controller" do
        it "allows using the action name to dispatch the action" do
          record_last_process

          parameters = {:foo => "bar"}
          session = {:baz => "bat"}
          flash = {:quux => "wibble"}

          subject.get :show, parameters, session, flash
          subject.last_process.must_equal [:show, 'GET', parameters, session, flash]

          subject.post :create, parameters, session, flash
          subject.last_process.must_equal [:create, 'POST', parameters, session, flash]

          subject.put :update, parameters, session, flash
          subject.last_process.must_equal [:update, 'PUT', parameters, session, flash]

          subject.delete :destroy, parameters, session, flash
          subject.last_process.must_equal [:destroy, 'DELETE', parameters, session, flash]

          subject.head :show, parameters, session, flash
          subject.last_process.must_equal [:show, 'HEAD', parameters, session, flash]
        end
      end
    end
  end
end
