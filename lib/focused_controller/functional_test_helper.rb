require 'active_support/concern'

module FocusedController
  module FunctionalTestHelper
    def get(*args)
      new_args = args_with_action_name(*args)
      super(*new_args)
    end

    def post(*args)
      super(*args_with_action_name(*args))
    end

    def put(*args)
      super(*args_with_action_name(*args))
    end

    def delete(*args)
      super(*args_with_action_name(*args))
    end

    def head(*args)
      super(*args_with_action_name(*args))
    end

    private

    def args_with_action_name(*args)
      if args.first.is_a?(Symbol)
        args
      else
        [FocusedController.action_name] + args
      end
    end
  end
end
