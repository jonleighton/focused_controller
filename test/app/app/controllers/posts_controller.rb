module PostsController
  class Action < ApplicationController
  end

  class Index < Action
    expose(:posts) { Post.all }
  end

  class Initializer < Action
    expose(:post) { Post.new params[:post] }
  end

  class New < Initializer
  end

  class Create < Initializer
    def call
      if post.save
        redirect_to post, :notice => 'Post was successfully created.'
      else
        render :action => "new"
      end
    end
  end

  class Finder < Action
    expose(:post) { Post.find params[:id] }
  end

  class Show < Finder
  end

  class Edit < Finder
  end

  class Update < Finder
    def call
      if post.update_attributes(params[:post])
        redirect_to post, :notice => 'Post was successfully updated.'
      else
        render :action => "edit"
      end
    end
  end

  class Destroy < Finder
    def call
      post.destroy
      redirect_to posts_url
    end
  end
end
