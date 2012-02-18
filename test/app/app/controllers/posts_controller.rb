class PostsController
  class Action < ApplicationController
  end

  class Index < Action
    def posts
      @posts ||= Post.all
    end
    helper_method :posts

    def run
    end
  end

  class Show < Action
    def post
      @post ||= Post.find(params[:id])
    end
    helper_method :post

    def run
    end
  end

  class New < Action
    def post
      @post ||= Post.new
    end
    helper_method :post

    def run
    end
  end

  class Edit < Action
    def post
      @post ||= Post.find(params[:id])
    end
    helper_method :post

    def run
    end
  end

  class Create < Action
    def post
      @post ||= Post.new(params[:post])
    end
    helper_method :post

    def run
      if post.save
        redirect_to post, notice: 'Post was successfully created.'
      else
        render action: "new"
      end
    end
  end

  class Update < Action
    def post
      @post ||= Post.find(params[:id])
    end
    helper_method :post

    def run
      if post.update_attributes(params[:post])
        redirect_to post, notice: 'Post was successfully updated.'
      else
        render action: "edit"
      end
    end
  end

  class Destroy < Action
    def post
      @post ||= Post.find(params[:id])
    end

    def run
      post.destroy
      redirect_to posts_url
    end
  end
end
