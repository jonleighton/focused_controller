module FocusedController
  class << self
    attr_accessor :action_name
  end
  self.action_name = 'run'
end
