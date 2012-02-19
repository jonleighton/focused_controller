require 'helper'
require 'action_controller'
require 'ostruct'

module FocusedController
  module TestHelper
    module FakePostsController
      class Action < ActionController::Base
      end

      class Index < Action
        def run
          if params[:omg]
            "omg"
          end
        end

        def self._routes
          OpenStruct.new(
            :named_routes => OpenStruct.new(
              :module => Module.new do
                def foo_path
                  '/foo'
                end
              end
            )
          )
        end
      end

      class Show < Action
        def self._routes
          OpenStruct.new(
            :named_routes => OpenStruct.new(
              :module => Module.new do
                def bar_path
                  '/bar'
                end
              end
            )
          )
        end
      end

      class TestCase < ActiveSupport::TestCase
        include FocusedController::TestHelper
      end

      class IndexTest < TestCase
      end

      class ShowTest < TestCase
      end

      class OtherShowTest < TestCase
        self.controller = Show
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
          test.new(nil).controller.is_a?(action).must_equal true
        end
      end

      subject { FakePostsController::IndexTest.new(nil) }

      def must_fail(&block)
        block.must_raise MiniTest::Assertion
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

        other = FakePostsController::ShowTest.new(nil)
        other.respond_to?(:foo_path).must_equal false
        other.respond_to?(:bar_path).must_equal true
        other.bar_path.must_equal '/bar'
      end

      it "has a #req method that sets params and calls the controller's #run" do
        subject.req(:omg => true).must_equal 'omg'
      end
    end
  end
end
