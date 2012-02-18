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

      route_set.router.recognize(req) do |route, matches, params|
        return route.app
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

      recognize('/posts').name.must_equal 'PostsController::Index'
      recognize('/comments').name.must_equal 'CommentsController::Index'
      recognize('/comments/4').name.must_equal 'CommentsController::Show'
      recognize('/comments/4', :method => :put).name.must_equal 'CommentsController::Update'
      recognize('/account').name.must_equal 'AccountsController::Show'
      recognize('/comments/4/replies').name.must_equal 'RepliesController::Index'
      recognize('/admin/comments').name.must_equal 'Admin::CommentsController::Index'
    end

    it "doesn't mess with callable routes" do
      app = Object.new
      def app.call; end

      route_set.draw do
        focused_controller_routes do
          match 'posts' => app
        end
      end
      recognize('/posts').must_equal app
    end
  end
end
