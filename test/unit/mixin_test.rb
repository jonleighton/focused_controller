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

      it "has a .call which dispatches the #run action" do
        def klass.action(name)
          if name.to_s == 'run'
            proc { |env| "omg" }
          end
        end

        klass.call(nil).must_equal "omg"
      end

      it "has an #action_name of 'show'" do
        subject.action_name.must_equal 'show'
      end

      it "uses the run method for the action" do
        subject.method_for_action('whatever').must_equal 'run'
      end

      it "removes all view assigns by default" do
        subject.view_assigns.must_equal({})
      end

      it "can be configured to allow view assigns" do
        subject.class.allow_view_assigns = true
        subject.instance_variable_set('@foo', 'bar')
        subject.view_assigns['foo'].must_equal('bar')
      end

      it "has a #run method by default" do
        subject.run.must_equal nil
      end
    end
  end
end
