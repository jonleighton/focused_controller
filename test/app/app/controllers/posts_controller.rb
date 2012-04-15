module PostsController
  class Action < ApplicationController
  end

  class Index < Action
    def posts
      @posts ||= Post.all
    end
    helper_method :posts
  end

  class Singular < Action
    def post
      @post ||= begin
        if params[:id]
          Post.find(params[:id])
        else
          Post.new(params[:post])
        end
      end
    end
    helper_method :post
  end

  class Show < Singular
  end

  class New < Singular
  end

  class Edit < Singular
  end

  class Create < Singular
    def run
      if post.save
        redirect_to post, :notice => 'Post was successfully created.'
      else
        render :action => "new"
      end
    end
  end

  class Update < Singular
    def run
      if post.update_attributes(params[:post])
        redirect_to post, :notice => 'Post was successfully updated.'
      else
        render :action => "edit"
      end
    end
  end

  class Destroy < Singular
    def run
      post.destroy
      redirect_to posts_url
    end
  end
end
