require 'isolated_test_helper'
require APP_ROOT + '/controllers/application_controller'
require APP_ROOT + '/controllers/posts_controller'
require APP_ROOT + '/models/post'

module PostsController
  class TestCase < ActiveSupport::TestCase
    include FocusedController::TestHelper
    stub_url :post, :posts

    setup do
      @post = Post.create(:title => 'Hello', :body => 'Omg')
    end
  end

  class IndexTest < TestCase
    test "should get index" do
      controller.call
      assert_response :success
      assert_not_nil controller.posts
    end
  end

  class NewTest < TestCase
    test "should get new" do
      controller.call
      assert_response :success
    end
  end

  class CreateTest < TestCase
    test "should create post" do
      controller.params = { :post => @post.attributes }

      assert_difference('Post.count') do
        controller.call
      end

      assert_redirected_to post_url(controller.post)
    end
  end

  class ShowTest < TestCase
    test "should show post" do
      controller.params = { :id => @post.id }
      controller.call
      assert_response :success
    end
  end

  class EditTest < TestCase
    test "should get edit" do
      controller.params = { :id => @post.id }
      controller.call
      assert_response :success
    end
  end

  class UpdateTest < TestCase
    test "should update post" do
      controller.params = { :id => @post.id }
      controller.call
      assert_redirected_to post_url(controller.post)
    end
  end

  class DestroyTest < TestCase
    test "should destroy post" do
      controller.params = { :id => @post.id }

      assert_difference('Post.count', -1) do
        controller.call
      end

      assert_redirected_to posts_url
    end
  end
end
