require 'active_support/concern'

module FocusedController
  module FunctionalTestHelper
    def get(*args)
      super(FocusedController.action_name, *args)
    end

    def post(*args)
      super(FocusedController.action_name, *args)
    end

    def put(*args)
      super(FocusedController.action_name, *args)
    end

    def delete(*args)
      super(FocusedController.action_name, *args)
    end

    def head(*args)
      super(FocusedController.action_name, *args)
    end
  end
end
