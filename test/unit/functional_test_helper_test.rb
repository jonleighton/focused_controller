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

        parameters = {:foo => "bar"}
        session = {:baz => "bat"}
        flash = {:quux => "wibble"}


        subject.get parameters, session, flash
        subject.last_process.must_equal ['call', parameters, session, flash, 'GET']

        subject.post parameters, session, flash
        subject.last_process.must_equal ['call', parameters, session, flash, 'POST']

        subject.put parameters, session, flash
        subject.last_process.must_equal ['call', parameters, session, flash, 'PUT']

        subject.delete parameters, session, flash
        subject.last_process.must_equal ['call', parameters, session, flash, 'DELETE']

        subject.head parameters, session, flash
        subject.last_process.must_equal ['call', parameters, session, flash, 'HEAD']
      end


      describe "testing a non-focused controller" do
        it "allows using the action name to dispatch the action" do
          subject.singleton_class.class_eval do
            attr_reader :last_process

            def process(*args)
              @last_process = args
            end
          end

          parameters = {:foo => "bar"}
          session = {:baz => "bat"}
          flash = {:quux => "wibble"}

          subject.get :show, parameters, session, flash
          subject.last_process.must_equal [:show, parameters, session, flash, 'GET']

          subject.post :create, parameters, session, flash
          subject.last_process.must_equal [:create, parameters, session, flash, 'POST']

          subject.put :update, parameters, session, flash
          subject.last_process.must_equal [:update, parameters, session, flash, 'PUT']

          subject.delete :destroy, parameters, session, flash
          subject.last_process.must_equal [:destroy, parameters, session, flash, 'DELETE']

          subject.head :show, parameters, session, flash
          subject.last_process.must_equal [:show, parameters, session, flash, 'HEAD']
        end
      end
    end
  end
end
