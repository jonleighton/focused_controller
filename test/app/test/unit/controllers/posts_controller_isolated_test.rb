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
      req
      assert_response :success
      assert_not_nil controller.posts
    end
  end

  class NewTest < TestCase
    test "should get new" do
      req
      assert_response :success
    end
  end

  class CreateTest < TestCase
    test "should create post" do
      assert_difference('Post.count') do
        req :post => @post.attributes
      end

      assert_redirected_to post_url(controller.post)
    end
  end

  class ShowTest < TestCase
    test "should show post" do
      req :id => @post.id
      assert_response :success
    end
  end

  class EditTest < TestCase
    test "should get edit" do
      req :id => @post.id
      assert_response :success
    end
  end

  class UpdateTest < TestCase
    test "should update post" do
      req :id => @post.id
      assert_redirected_to post_url(controller.post)
    end
  end

  class DestroyTest < TestCase
    test "should destroy post" do
      assert_difference('Post.count', -1) do
        req :id => @post.id
      end

      assert_redirected_to posts_url
    end
  end
end
