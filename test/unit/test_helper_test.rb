require 'helper'
require 'focused_controller/test_helper'
require 'action_controller'

module FocusedController
  module TestHelper
    module FakePostsController
      class Action < ActionController::Base
      end

      class Index < Action
        def run
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
        subject.req(:set_session => true)
        subject.session[:foo].must_equal 'omg'
        subject.session['foo'].must_equal 'omg'
      end

      it 'supports flash' do
        subject.req(:set_flash => true)
        subject.flash[:foo].must_equal 'omg'

        # This is consistent with the behaviour of standard rails functional tests
        subject.flash['foo'].must_equal nil
      end

      it 'supports cookies' do
        subject.req(:set_cookie => true)
        subject.cookies[:foo].must_equal 'omg'
      end

      describe "#req" do
        it "sets params and calls the controller's #run" do
          subject.req(:omg => true).must_equal 'omg'
        end

        it 'sets session' do
          subject.req(nil, { :foo => 'bar' })
          subject.session[:foo].must_equal 'bar'
        end

        it 'set flash' do
          subject.req(nil, nil, { :foo => 'bar' })
          subject.flash[:foo].must_equal 'bar'
        end

        it "doesn't overwrite existing params, session, or flash if new ones aren't provided" do
          subject.controller.params[:param] = true
          subject.controller.flash[:flash] = true
          subject.controller.session[:session] = true

          subject.req

          subject.controller.params[:param].must_equal true
          subject.controller.flash[:flash].must_equal true
          subject.controller.session[:session].must_equal true

          subject.req({})

          subject.controller.params[:param].must_equal(nil)
        end
      end
    end
  end
end
