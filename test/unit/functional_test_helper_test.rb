require 'helper'
require 'action_controller/test_case'

module FocusedController
  module FunctionalTestHelper
    class FakeTestCase
    end

    class FakePostsController
      class Index; end
      class Show; end

      class TestCase < ActionController::TestCase
        include FocusedController::FunctionalTestHelper
      end

      class IndexTest < TestCase
      end

      class ShowTest < TestCase
      end
    end

    describe FunctionalTestHelper do
      it 'automatically determines the controller class' do
        FakePostsController::IndexTest.controller_class.
          must_equal FakePostsController::Index
        FakePostsController::ShowTest.controller_class.
          must_equal FakePostsController::Show
      end
    end
  end
end
