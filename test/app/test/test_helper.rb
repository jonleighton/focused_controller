ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'focused_controller/functional_test_helper'
require 'focused_controller/test_helper'

# Disable fixtures
module ActiveRecord::TestFixtures
  def setup_fixtures; end
  def teardown_fixtures; end
end
