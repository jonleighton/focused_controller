require 'focused_controller/version'
require 'focused_controller/route'
require 'focused_controller/mixin'
require 'focused_controller/route_mapper'
require 'focused_controller/functional_test_helper'
require 'focused_controller/test_helper'

module FocusedController
  class << self
    attr_accessor :action_name
  end
  self.action_name = 'run'
end
