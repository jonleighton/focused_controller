# Focused Controller #

[![Build Status](https://secure.travis-ci.org/jonleighton/focused_controller.png?branch=master)](http://travis-ci.org/jonleighton/focused_controller)

Focused Controller alters Rails' conventions so that each individual action in
a controller is represented by its own class. This makes it easier to break up
the code within an action and share code between different actions.

Focused Controller also provides test helpers which enable you to write unit
tests for your controller code. This is much faster than functional testing,
and better suited to testing fine grained logic that may exist in your actions.

[I wrote a blog post to fully explain the
idea](http://jonathanleighton.com/articles/2012/explaining-focused-controller/).

There is a [mailing list](http://groups.google.com/group/focused_controller)
for discussion.

## Synopsis ##

``` ruby
class ApplicationController
  class Action < ApplicationController
    include FocusedController::Mixin
  end
end

module PostsController
  class Action < ApplicationController::Action
    before_filter :authenticate
  end

  class Index < Action
    expose(:posts) { Post.recent.limit(5) }
  end

  class New < Action
    expose(:post) { Post.new }
  end

  class Singular < Action
    expose(:post) { Post.find params[:id] }
    before_filter { redirect_to root_path unless post.accessible_to?(current_user) }
  end

  class Show < Singular
  end

  class Update < Singular
    def call
      if post.update_attributes(params[:post])
        # ...
      else
        # ...
      end
    end
  end
end
```

You can include `FocusedController::Mixin` anywhere, so you don't have
to use Focused Controller in every single controller if you don't want
to. I find it useful to define `ApplicationController::Action` and
inherit from that where needed.

The `#call` method is what gets invoked when the request is served.

The `#expose` declaration defines a method which runs the block and
memoizes the result. It also makes `post` a helper method so you can
call it from the view template.

The `before_filter` in Singular is inherited by precisely the actions
that need it, so we don't need to specify `:only` or `:except`.

## Routing ##

Rails' normal routing assumes your actions are methods inside an object
whose name ends with 'controller'. For example:

``` ruby
get '/posts/new' => 'posts#new'
```

will route `GET /posts/new` to `PostsController#new`.

To get around this, we use the `focused_controller_routes` helper:

``` ruby
Loco2::Application.routes.draw do
  focused_controller_routes do
    get '/posts/new' => 'posts#new'
  end
end
```

The route will now map to `PostsController::New#call`.

All the normal routing macros are also supported:

``` ruby
focused_controller_routes do
  resources :posts
end
```

## Functional Testing ##

If you wish, focused controllers can be tested in the classical
'functional' style. It no longer makes sense to specify the method name
to be called as it would always be `#call`. So this is omitted:

``` ruby
require 'focused_controller/functional_test_helper'
require_dependency 'users_controller'

module UsersController
  class CreateTest < ActionController::TestCase
    include FocusedController::FunctionalTestHelper

    test "should create user" do
      assert_difference('User.count') do
        post user: { name: 'Jon' }
      end

      assert_redirected_to user_path(@controller.user)
    end
  end
end
```

There is also an equivalent helper for RSpec:

``` ruby
require 'focused_controller/rspec_functional_helper'

describe UsersController do
  include FocusedController::RSpecFunctionalHelper

  describe UsersController::Create do
    it "should create user" do
      expect { post user: { name: 'Jon' } }.to change(User, :count).by(1)
      response.should redirect_to(user_path(subject.user))
    end
  end
end
```

## Unit Testing ##

Unit testing is faster and better suited to testing logic than
functional testing. To do so, you instantiate your action class and call
methods on it:

``` ruby
module UsersController
  class ShowTest < ActiveSupport::TestCase
    test 'finds the user' do
      user = User.create

      controller = UsersController::Show.new
      controller.params = { id: user.id }

      assert_equal user, controller.user
    end
  end
end
```

### The `#call` method ###

Testing the code in your `#call` method is a little more involved,
depending on what's in it. For example, your `#call` method may use
(explicitly or implicitly) any of the following objects:

* request
* response
* params
* session
* flash
* cookies

To make the experience smoother, Focused Controller sets up mock
versions of these objects, much like with classical functional testing.
It also provides accessors for these objects in your test class.

``` ruby
require 'focused_controller/test_helper'
require_dependency 'users_controller'

module UsersController
  class CreateTest < ActiveSupport::TestCase
    include FocusedController::TestHelper

    test "should create user" do
      controller.params = { user: { name: 'Jon' } }

      assert_difference('User.count') do
        controller.call
      end

      assert_redirected_to user_path(controller.user)
    end
  end
end
```

### Assertions ###

You have access to the normal assertions found in Rails' functional tests:

* `assert_template`
* `assert_response`
* `assert_redirected_to`

### Filters ###

In unit tests, we're not testing through the Rack stack. We're just calling the
`#call` method. Therefore, filters do not get run. If some filter code is
crucial to what your action is doing then you should move it out of the filter.
If the filter code is separate, then you might want to unit-test it separately,
or you might decide that covering it in integration/acceptance tests is
sufficient.

### RSpec ###

There is a helper for RSpec as well:

``` ruby
require 'focused_controller/rspec_helper'

describe UsersController do
  include FocusedController::RSpecHelper

  describe UsersController::Create do
    it "creates a user" do
      subject.params = { user: { name: 'Jon' } }
      expect { subject.call }.to change(User, :count).by(1)
      response.should redirect_to(user_path(subject.user))
    end
  end
end
```

## More examples ##

The [acceptance
tests](https://github.com/jonleighton/focused_controller/tree/master/test/acceptance)
for Focused Controller exercise a [complete Rails
application](https://github.com/jonleighton/focused_controller/tree/master/test/app),
which uses the plugin. Therefore, you might wish to look there to get
more of an idea about how it can be used.

(Note that the code there is based on Rails' scaffolding, not how I
would typically write controllers and tests.)
