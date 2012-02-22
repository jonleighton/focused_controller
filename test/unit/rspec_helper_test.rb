require 'helper'
require 'action_controller'
require 'focused_controller/rspec_helper'

module FocusedController
  module RSpecHelper
    module FakePostsController
      class Action < ActionController::Base
      end

      class Index < Action
      end

      class Show < Action
      end

      class Edit < Action
      end

      class Destroy < Action
      end
    end

    index_spec = RSpec::Core::ExampleGroup.describe FakePostsController::Index do
      include FocusedController::RSpecHelper
    end

    show_spec = nil
    inner_show_spec = nil
    RSpec::Core::ExampleGroup.describe FakePostsController do
      show_spec = describe FakePostsController::Show do
        include FocusedController::RSpecHelper

        inner_show_spec = describe 'foo' do
        end
      end
    end

    edit_spec = RSpec::Core::ExampleGroup.describe "the edit action" do
      include FocusedController::RSpecHelper
      self.controller = FakePostsController::Edit
    end

    describe RSpecHelper do
      it 'finds the correct controller class' do
        index_spec.controller.must_equal FakePostsController::Index
        show_spec.controller.must_equal FakePostsController::Show
        inner_show_spec.controller.must_equal FakePostsController::Show
        edit_spec.controller.must_equal FakePostsController::Edit
      end

      subject { index_spec.new }

      def must_fail(&block)
        block.must_raise RSpec::Expectations::ExpectationNotMetError
      end

      def must_succeed(&block)
        block.call
        true.must_equal true # to count the assertion
      end

      it 'has a redirect_to matcher' do
        must_fail { subject.should subject.redirect_to('/foo') }
        subject.controller.redirect_to('/foo')
        must_succeed { subject.should subject.redirect_to('/foo') }
      end

      it 'matches response type' do
        must_succeed { subject.response.should subject.be_success }
        must_fail    { subject.response.should subject.be_error }

        subject.controller.render :status => :not_found

        must_fail    { subject.response.should subject.be_success }
        must_succeed { subject.response.should subject.be_missing }
      end

      it 'has a render_template matcher' do
        subject.controller.render :foo

        must_succeed { subject.response.should subject.render_template(:foo) }
        must_fail    { subject.response.should subject.render_template(:bar) }
      end

      it 'sets the subject to be the controller instance' do
        subject.subject.must_equal subject.controller
      end
    end
  end
end
