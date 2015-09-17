require_relative '../helper'
require 'focused_controller/test_helper'
require 'action_controller'

module FocusedController
  module TestHelper
    module FakePostsController
      class Action < ActionController::Base
      end

      class Index < Action
        def call
          if params[:omg]
            "omg"
          elsif params[:set_session]
            session[:foo] = 'omg'
          elsif params[:set_flash]
            flash[:foo] = 'omg'
          elsif params[:set_cookie]
            cookies[:foo] = 'omg'
          end
        end

        def self._routes
          OpenStruct.new(
            :url_helpers => Module.new do
              def foo_path
                '/foo'
              end
            end
          )
        end
      end

      class Show < Action
        def self._routes
          OpenStruct.new(
            :url_helpers => Module.new do
              def bar_path
                '/bar'
              end
            end
          )
        end
      end

      class TestCase < ActiveSupport::TestCase
        include FocusedController::TestHelper

        def initialize(method_name = :foo)
          super
          @_result = OpenStruct.new
        end
        def foo; end
      end

      class IndexTest < TestCase
      end

      class ShowTest < TestCase
      end

      class OtherShowTest < TestCase
        self.controller_class = Show
      end

      class OtherOtherShowTest < OtherShowTest
      end
    end

    describe TestHelper do
      it 'instantiates the correct controller' do
        mappings = {
          FakePostsController::IndexTest          => FakePostsController::Index,
          FakePostsController::ShowTest           => FakePostsController::Show,
          FakePostsController::OtherShowTest      => FakePostsController::Show,
          FakePostsController::OtherOtherShowTest => FakePostsController::Show
        }

        mappings.each do |test, action|
          test.new.controller.is_a?(action).must_equal true
        end
      end

      let(:controller) { subject.controller }

      subject { FakePostsController::IndexTest.new }

      def must_fail(&block)
        block.must_raise ActiveSupport::TestCase::Assertion
      end

      def must_succeed(&block)
        block.call
        # this is just so the assertion is counted. the block will
        # raise if it fails
        assert_equal true, true
      end

      it 'supports assert_template :foo' do
        subject.controller.render :foo
        must_succeed { subject.assert_template :foo }
        must_fail    { subject.assert_template :bar }
      end

      it "supports assert_template 'foo'" do
        subject.controller.render :foo
        must_succeed { subject.assert_template 'foo' }
        must_fail    { subject.assert_template 'bar' }
      end

      it 'supports assert_response :success' do
        must_succeed { subject.assert_response :success }
        must_fail    { subject.assert_response :error }

        subject.controller.render 'foo'

        must_succeed { subject.assert_response :success }
        must_fail    { subject.assert_response :error }
      end

      it 'supports assert_response :redirect' do
        must_fail { subject.assert_response :redirect }

        subject.controller.redirect_to 'foo'
        must_succeed { subject.assert_response :redirect }
      end

      it 'supports assert_redirected_to' do
        must_fail { subject.assert_redirected_to '/foo' }

        subject.controller.redirect_to '/foo'

        must_succeed { subject.assert_redirected_to '/foo' }
        must_fail    { subject.assert_redirected_to '/bar' }
      end

      it "responds to the controller's url helpers" do
        subject.respond_to?(:foo_path).must_equal true
        subject.respond_to?(:bar_path).must_equal false
        subject.foo_path.must_equal '/foo'

        other = FakePostsController::ShowTest.new
        other.respond_to?(:foo_path).must_equal false
        other.respond_to?(:bar_path).must_equal true
        other.bar_path.must_equal '/bar'
      end

      it 'supports session' do
        controller.params = { :set_session => true }
        controller.call

        subject.session[:foo].must_equal 'omg'
        subject.session['foo'].must_equal 'omg'
      end

      it 'supports flash' do
        controller.params = { :set_flash => true }
        controller.call

        subject.flash[:foo].must_equal 'omg'

        # This is consistent with the behaviour of standard rails functional tests
        if Gem::Version.new(Rails::VERSION::STRING) < Gem::Version.new('4.1.0')
          subject.flash['foo'].must_equal nil
        else
          subject.flash['foo'].must_equal 'omg'
        end
      end

      it 'supports cookies' do
        controller.params = { :set_cookie => true }
        controller.call

        subject.cookies[:foo].must_equal 'omg'
      end
    end
  end
end
