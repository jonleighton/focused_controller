require 'action_dispatch'

module FocusedController
  # The monkey-patching in this file makes me sadface but I can't see
  # another way ;(
  class RouteMapper
    def initialize(scope, options)
      @scope, @options = scope, options
    end

    def options
      options = @options.dup

      if to = to_option
        options[:to] = FocusedController::Route.new(to)
        options.delete(:action)
      end

      options
    end

    private

    def to_option
      if @options[:to] && !@options[:to].respond_to?(:call)
        @options[:to]
      elsif @options[:action] && @scope[:controller]
        name = ''
        name << @scope[:module].camelize << '::' if @scope[:module]
        name << @scope[:controller].camelize << 'Controller::'
        name << @options[:action].to_s.camelize
        name
      end
    end
  end

  class ActionDispatch::Routing::Mapper
    def focused_controller_routes(&block)
      prev, @scope[:focused_controller_routes] = @scope[:focused_controller_routes], true
      yield
    ensure
      @scope[:focused_controller_routes] = false
    end

    class Mapping
      def initialize_with_focused_controller(set, scope, path, options)
        if scope[:focused_controller_routes]
          options = FocusedController::RouteMapper.new(scope, options).options
        end

        initialize_without_focused_controller(set, scope, path, options)
      end

      alias_method_chain :initialize, :focused_controller
    end
  end
end
