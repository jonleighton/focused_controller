require 'helper'

module FocusedController
  module Test
    class MixinTestBaseController
      def view_assigns
        {'some' => 'var'}
      end
    end

    class MixinTestController < MixinTestBaseController
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
      subject do
        klass = Class.new(FocusedController::Test::MixinTestController)
        klass.name = "PostsController::Show"
        klass.new
      end

      it "has a .controller_name of 'posts'" do
        subject.class.controller_path.must_equal 'posts'
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
        subject.view_assigns.must_equal({'some' => 'var'})
      end

      it "has a #run method by default" do
        subject.run.must_equal nil
      end
    end
  end
end
