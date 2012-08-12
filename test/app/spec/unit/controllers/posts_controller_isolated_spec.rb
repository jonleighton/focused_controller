require 'isolated_spec_helper'
require APP_ROOT + '/controllers/application_controller'
require APP_ROOT + '/controllers/posts_controller'
require APP_ROOT + '/models/post'

describe PostsController do
  include FocusedController::RSpecHelper
  stub_url :post, :posts

  before do
    @post = Post.create(:title => 'Hello', :body => 'Omg')
  end

  describe PostsController::Index do
    it "should get index" do
      subject.call
      response.should be_success
      subject.posts.should_not be(:nil)
    end
  end

  describe PostsController::New do
    it "should get new" do
      subject.call
      response.should be_success
    end
  end

  describe PostsController::Create do
    it "should create post" do
      subject.params = { :post => @post.attributes }
      expect { subject.call }.to change(Post, :count).by(1)
      response.should redirect_to(post_url(subject.post))
    end
  end

  describe PostsController::Show do
    it "should show post" do
      subject.params = { :id => @post.id }
      subject.call
      response.should be_success
    end
  end

  describe PostsController::Edit do
    it "should get edit" do
      subject.params = { :id => @post.id }
      subject.call
      response.should be_success
    end
  end

  describe PostsController::Update do
    it "should update post" do
      subject.params = { :id => @post.id }
      subject.call
      response.should redirect_to(post_url(subject.post))
    end
  end

  describe PostsController::Destroy do
    it "should destroy post" do
      subject.params = { :id => @post.id }
      expect { subject.call }.to change(Post, :count).by(-1)
      response.should redirect_to(posts_url)
    end
  end
end
