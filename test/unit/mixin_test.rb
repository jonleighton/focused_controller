require 'helper'
require 'action_controller'

module FocusedController
  module Test
    class MixinTestBaseController
      def view_assigns
        {'some' => 'var'}
      end
    end

    class MixinTestController < ActionController::Base
      include FocusedController::Mixin

      class << self
        attr_accessor :name
      end
    end
  end
end

module FocusedController
  describe Mixin do
    describe "with a PostsController::Show class" do
      let(:klass) do
        klass = Class.new(FocusedController::Test::MixinTestController)
        klass.name = "PostsController::Show"
        klass
      end

      subject { klass.new }

      it "has a .controller_path of 'posts'" do
        klass.controller_path.must_equal 'posts'
      end

      it "has a .call which dispatches the #call action" do
        def klass.action(name)
          if name.to_s == 'call'
            proc { |env| "omg" }
          end
        end

        klass.call(nil).must_equal "omg"
      end

      it "has an #action_name of 'show'" do
        subject.action_name.must_equal 'show'
      end

      it "has a #controller_name of 'posts'" do
        subject.controller_name.must_equal 'posts'
      end

      it "uses the call method for the action" do
        subject.method_for_action('whatever').must_equal 'call'
      end

      it "removes all view assigns by default" do
        subject.view_assigns.must_equal({})
      end

      it "can be configured to allow view assigns" do
        subject.class.allow_view_assigns = true
        subject.instance_variable_set('@foo', 'bar')
        subject.view_assigns['foo'].must_equal('bar')
      end

      it "has a #call method by default" do
        subject.call.must_equal nil
      end
    end

    describe '.expose' do
      subject do
        @klass = Class.new do
          include FocusedController::Mixin

          @helper_methods = []

          class << self
            attr_reader :helper_methods

            def helper_method(name)
              @helper_methods << name
            end
          end
        end
      end

      it 'defines a method' do
        subject.expose(:foo) { 'bar' }
        subject.new.foo.must_equal 'bar'
      end

      it 'declares the method a helper method' do
        subject.expose(:foo) { 'bar' }
        subject.helper_methods.must_equal [:foo]
      end

      it 'memoizes the result' do
        count = 0
        counter = proc { count += 1 }
        subject.expose(:foo) { counter.call }

        obj = subject.new
        obj.foo.must_equal 1
        obj.foo.must_equal 1
      end

      it 'it memoizes falsey values' do
        val = true
        meth = proc { val = !val }
        subject.expose(:foo) { meth.call }

        obj = subject.new
        obj.foo.must_equal false
        obj.foo.must_equal false
      end

      it 'instance evals the block' do
        subject.expose(:foo) { @bar }
        obj = subject.new
        obj.instance_variable_set('@bar', 'bar')
        obj.foo.must_equal 'bar'
      end

      it 'declares an attr_reader when called without a block' do
        subject.expose :foo
        subject.helper_methods.must_equal [:foo]

        obj = subject.new
        obj.instance_variable_set('@foo', 'bar')
        obj.foo.must_equal 'bar'
      end
    end
  end
end
