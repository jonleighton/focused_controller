module PostsController
  class Index < ApplicationController
    expose(:posts) { Post.all }
  end

  class New < ApplicationController
    expose(:post) { Post.new params[:post] }
  end

  class Create < New
    def call
      if post.save
        redirect_to post, :notice => 'Post was successfully created.'
      else
        render :action => "new"
      end
    end
  end

  class Show < ApplicationController
    expose(:post) { Post.find params[:id] }
  end

  class Edit < Show
  end

  class Update < Edit
    def call
      if post.update_attributes(params[:post])
        redirect_to post, :notice => 'Post was successfully updated.'
      else
        render :action => "edit"
      end
    end
  end

  class Destroy < Edit
    def call
      post.destroy
      redirect_to posts_url
    end
  end
end
