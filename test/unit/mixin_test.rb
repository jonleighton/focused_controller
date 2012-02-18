require 'helper'

module FocusedController
  module Test
    class MixinTestController
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
    end
  end
end
