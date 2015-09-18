require_relative '../helper'

# RouteSet is missing some requires
require 'active_support/core_ext/uri'
require 'active_support/core_ext/enumerable'

module FocusedController
  describe RouteMapper do
    let(:route_set) { ActionDispatch::Routing::RouteSet.new }

    def recognize(path, environment = {})
      method = (environment[:method] || "GET").to_s.upcase
      env    = Rack::MockRequest.env_for(path, {:method => method})
      req    = route_set.request_class.new(env)
      router = route_set.router

      router.recognize(req) do |route, matches, params|
        return route
      end

      raise ArgumentError, "'#{path}' not recognized"
    end

    it 'creates routes that map to focused controllers' do
      route_set.draw do
        focused_controller_routes do
          get 'posts'      => 'PostsController::Index'
          get 'posts/all'  => 'posts#index'
          get 'posts/all2' => 'PostsController::Index'

          resources :comments do
            resources :replies

            get 'a/:foo' => 'PostsController::Index', on: :collection
            get 'b/:foo', action: :index, on: :collection
          end

          resource :account

          namespace :admin do
            resources :comments
            get 'foo' => 'FooController::Show'
          end
        end
      end

      mappings = {
        [:get, '/posts']              => 'PostsController::Index',
        [:get, '/posts/all']          => 'PostsController::Index',
        [:get, '/comments']           => 'CommentsController::Index',
        [:get, '/comments/4']         => 'CommentsController::Show',
        [:put, '/comments/4']         => 'CommentsController::Update',
        [:get, '/account']            => 'AccountsController::Show',
        [:get, '/comments/4/replies'] => 'RepliesController::Index',
        [:get, '/admin/comments']     => 'Admin::CommentsController::Index',
        [:get, '/comments/a/omg']     => 'PostsController::Index',
        [:get, '/comments/b/omg']     => 'CommentsController::Index',
        [:get, '/admin/foo']          => 'Admin::FooController::Show',
        [:get, '/posts/all2']         => 'PostsController::Index',
      }

      mappings.each do |(method, path), controller|
        route = recognize(path, :method => method)
        route.defaults[:action].must_equal FocusedController.action_name
        route.defaults[:controller].must_equal controller.underscore
      end
    end

    it "doesn't mess with callable routes" do
      app = Object.new
      def app.call; end

      route_set.draw do
        focused_controller_routes do
          get 'posts' => app
        end
      end
      route = recognize('/posts')
      app   = route.app

      # Remove this when we drop Rails 4.1
      app = app.app if app.respond_to?(:app)

      app.must_equal app
    end

    it "generates a route with url_for" do
      route_set.draw do
        focused_controller_routes do
          resources :posts

          namespace :admin do
            resources :comments
          end
        end
      end

      path = route_set.url_for(controller: "posts_controller/index", action: "call", page: "2", only_path: true)
      path.must_equal "/posts?page=2"

      path = route_set.url_for(controller: "admin/comments_controller/show", action: "call", id: "62", page: "2", only_path: true)
      path.must_equal "/admin/comments/62?page=2"
    end
  end
end
