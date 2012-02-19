ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Disable fixtures
module ActiveRecord::TestFixtures
  def setup_fixtures; end
  def teardown_fixtures; end
end
