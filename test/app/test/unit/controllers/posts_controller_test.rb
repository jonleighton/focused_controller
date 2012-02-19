require 'test_helper'

class PostsController
  class TestCase < ActiveSupport::TestCase
    include FocusedController::TestHelper

    setup do
      @post = Post.create(:title => 'Hello', :body => 'Omg')
    end
  end

  class IndexTest < TestCase
    test "should get index" do
      controller.run
      assert_response :success
      assert_not_nil controller.posts
    end
  end

  class NewTest < TestCase
    test "should get new" do
      controller.run
      assert_response :success
    end
  end

  class CreateTest < TestCase
    setup { controller.params = { :post => @post.attributes } }

    test "should create post" do
      assert_difference('Post.count') do
        controller.run
      end

      assert_redirected_to post_path(controller.post)
    end
  end

  class ShowTest < TestCase
    setup { controller.params = { :id => @post.id } }

    test "should show post" do
      controller.run
      assert_response :success
    end
  end

  class EditTest < TestCase
    setup { controller.params = { :id => @post.id } }

    test "should get edit" do
      controller.run
      assert_response :success
    end
  end

  class UpdateTest < TestCase
    setup { controller.params = { :id => @post.id } }

    test "should update post" do
      controller.run
      assert_redirected_to post_path(@controller.post)
    end
  end

  class DestroyTest < TestCase
    setup { controller.params = { :id => @post.id } }

    test "should destroy post" do
      assert_difference('Post.count', -1) do
        controller.run
      end

      assert_redirected_to posts_path
    end
  end
end
