require 'test_helper'

class PostsController
  class TestCase < ActionController::TestCase
    include FocusedController::FunctionalTestHelper

    setup do
      @post = Post.create(:title => 'Hello', :body => 'Omg')
    end
  end

  class IndexTest < TestCase
    test "should get index" do
      get
      assert_response :success
      assert_not_nil @controller.posts
    end
  end

  class NewTest < TestCase
    test "should get new" do
      get
      assert_response :success
    end
  end

  class CreateTest < TestCase
    test "should create post" do
      assert_difference('Post.count') do
        post post: @post.attributes
      end

      assert_redirected_to post_path(@controller.post)
    end
  end

  class ShowTest < TestCase
    test "should show post" do
      get id: @post
      assert_response :success
    end
  end

  class EditTest < TestCase
    test "should get edit" do
      get id: @post
      assert_response :success
    end
  end

  class UpdateTest < TestCase
    test "should update post" do
      put id: @post, post: @post.attributes
      assert_redirected_to post_path(@controller.post)
    end
  end

  class DestroyTest < TestCase
    test "should destroy post" do
      assert_difference('Post.count', -1) do
        delete id: @post
      end

      assert_redirected_to posts_path
    end
  end
end
