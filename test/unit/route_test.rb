require_relative '../helper'

module FocusedController
  module Test
  end

  describe Route do
    let(:controller) { Object.new }
    subject { Route.new('FocusedController::Test::RouteTestController') }

    before do
      Test.const_set(:RouteTestController, controller)
    end

    after do
      Test.send(:remove_const, :RouteTestController)
    end

    describe '#call' do
      it 'constantizes the name and invokes #call on the constant' do
        env, resp = Object.new, Object.new

        # Not using MiniTest::Mock for this because it caused problems
        # with Rubinius
        controller.singleton_class.send :define_method, :call do |call_env|
          resp if call_env == env
        end

        subject.call(env).must_equal resp
      end
    end

    describe '#to_s' do
      it "returns the the name" do
        subject.to_s.must_equal 'FocusedController::Test::RouteTestController'
      end
    end
  end
end
