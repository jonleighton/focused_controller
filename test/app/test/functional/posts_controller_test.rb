require 'test_helper'

class PostsController
  class TestCase < ActionController::TestCase
    setup do
      @post = Post.create(:title => 'Hello', :body => 'Omg')
    end
  end

  class IndexTest < TestCase
    tests Index

    test "should get index" do
      get :run
      assert_response :success
      assert_not_nil @controller.posts
    end
  end

  class NewTest < TestCase
    tests New

    test "should get new" do
      get :run
      assert_response :success
    end
  end

  class CreateTest < TestCase
    tests Create

    test "should create post" do
      assert_difference('Post.count') do
        post :run, post: @post.attributes
      end

      assert_redirected_to post_path(@controller.post)
    end
  end

  class ShowTest < TestCase
    tests Show

    test "should show post" do
      get :run, id: @post
      assert_response :success
    end
  end

  class EditTest < TestCase
    tests Edit

    test "should get edit" do
      get :run, id: @post
      assert_response :success
    end
  end

  class UpdateTest < TestCase
    tests Update

    test "should update post" do
      put :run, id: @post, post: @post.attributes
      assert_redirected_to post_path(@controller.post)
    end
  end

  class DestroyTest < TestCase
    tests Destroy

    test "should destroy post" do
      assert_difference('Post.count', -1) do
        delete :run, id: @post
      end

      assert_redirected_to posts_path
    end
  end
end
