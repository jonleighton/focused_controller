require 'helper'

module FocusedController
  module Test
  end

  describe Route do
    let(:controller) { MiniTest::Mock.new }
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
        controller.expect :call, resp, [env]

        subject.call(env).must_equal resp
        controller.verify
      end
    end

    describe '#to_s' do
      it "returns the the name, plus '#run'" do
        subject.to_s.must_equal 'FocusedController::Test::RouteTestController#run'
      end
    end
  end
end
