require 'focused_controller/version'
require 'focused_controller/route'
require 'focused_controller/mixin'

module FocusedController
  class << self
    attr_accessor :action_name
  end
  self.action_name = 'run'
end
