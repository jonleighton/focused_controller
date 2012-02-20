require 'helper'

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

      if route_set.respond_to?(:router)
        router = route_set.router # Rails 3.2+
      else
        router = route_set.set    # Rails 3.0, 3.1
      end

      router.recognize(req) do |route, matches, params|
        return route
      end
    end

    it 'creates routes that map to focused controllers' do
      route_set.draw do
        focused_controller_routes do
          match 'posts' => 'PostsController::Index'

          resources :comments do
            resources :replies
          end

          resource :account

          namespace :admin do
            resources :comments
          end
        end
      end

      mappings = {
        [:get, '/posts']              => 'PostsController::Index',
        [:get, '/comments']           => 'CommentsController::Index',
        [:get, '/comments/4']         => 'CommentsController::Show',
        [:put, '/comments/4']         => 'CommentsController::Update',
        [:get, '/account']            => 'AccountsController::Show',
        [:get, '/comments/4/replies'] => 'RepliesController::Index',
        [:get, '/admin/comments']     => 'Admin::CommentsController::Index'
      }

      mappings.each do |(method, path), controller|
        route = recognize(path, :method => method)
        route.app.name.must_equal controller
        route.defaults[:action].must_equal 'run'
      end
    end

    it "doesn't mess with callable routes" do
      app = Object.new
      def app.call; end

      route_set.draw do
        focused_controller_routes do
          match 'posts' => app
        end
      end
      recognize('/posts').app.must_equal app
    end
  end
end
