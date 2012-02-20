require 'spec_helper'

describe PostsController do
  include FocusedController::RSpecHelper

  before do
    @post = Post.create(:title => 'Hello', :body => 'Omg')
  end

  describe PostsController::Index do
    it "should get index" do
      req
      response.should be_success
      subject.posts.should_not be(:nil)
    end
  end

  describe PostsController::New do
    it "should get new" do
      req
      response.should be_success
    end
  end

  describe PostsController::Create do
    it "should create post" do
      expect { req :post => @post.attributes }.to change(Post, :count).by(1)
      response.should redirect_to(post_path(subject.post))
    end
  end

  describe PostsController::Show do
    it "should show post" do
      req :id => @post.id
      response.should be_success
    end
  end

  describe PostsController::Edit do
    it "should get edit" do
      req :id => @post.id
      response.should be_success
    end
  end

  describe PostsController::Update do
    it "should update post" do
      req :id => @post.id
      response.should redirect_to(post_path(subject.post))
    end
  end

  describe PostsController::Destroy do
    it "should destroy post" do
      expect { req :id => @post.id }.to change(Post, :count).by(-1)
      response.should redirect_to(posts_path)
    end
  end
end
