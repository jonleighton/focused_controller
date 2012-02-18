class PostsController
  class Action < ApplicationController
  end

  class Index < Action
    def run
      @posts = Post.all
    end
  end

  class Show < Action
    def run
      @post = Post.find(params[:id])
    end
  end

  class New < Action
    def run
      @post = Post.new
    end
  end

  class Edit < Action
    def run
      @post = Post.find(params[:id])
    end
  end

  class Create < Action
    def run
      @post = Post.new(params[:post])

      if @post.save
        redirect_to @post, notice: 'Post was successfully created.'
      else
        render action: "new"
      end
    end
  end

  class Update < Action
    def run
      @post = Post.find(params[:id])
      if @post.update_attributes(params[:post])
        redirect_to @post, notice: 'Post was successfully updated.'
      else
        render action: "edit"
      end
    end
  end

  class Destroy < Action
    def run
      @post = Post.find(params[:id])
      @post.destroy
      redirect_to posts_url
    end
  end
end
