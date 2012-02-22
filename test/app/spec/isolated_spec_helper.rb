require 'bundler/setup'
require 'rspec'
require 'focused_controller/rspec_helper'
require 'focused_controller/rspec_functional_helper'

require 'active_support/dependencies'
ActiveSupport::Dependencies.autoload_paths += Dir[File.expand_path('../../app/*', __FILE__)]

POSTS = []
