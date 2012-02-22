require 'action_controller'
require 'focused_controller'

class ApplicationController < ActionController::Base
  include FocusedController::Mixin
end
