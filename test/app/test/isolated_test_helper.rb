require 'bundler/setup'
require 'test/unit'
require 'active_support/test_case'
require 'focused_controller/functional_test_helper'
require 'focused_controller/test_helper'

require 'active_support/dependencies'
ActiveSupport::Dependencies.autoload_paths += Dir[File.expand_path('../../app/*', __FILE__)]

POSTS = []
