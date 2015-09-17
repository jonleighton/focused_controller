require 'focused_controller/action_name'
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
        options[:action]     = FocusedController.action_name
        options[:controller] = to.underscore

        options.delete :to
      end

      options
    end

    private

    def to_option
      if @options[:to] && !@options[:to].respond_to?(:call)
        if @options[:to].include?('#')
          stringify_controller_and_action(*@options[:to].split('#'))
        else
          @options[:to]
        end
      elsif @options[:controller]
        @options[:controller]
      elsif @options[:action] && @scope[:controller]
        stringify_controller_and_action(@scope[:controller], @options[:action])
      end
    end

    def stringify_controller_and_action(controller, action)
      "#{controller.to_s.underscore}_controller/#{action.to_s.underscore}"
    end
  end

  module RoutingExtensions
    def focused_controller_routes(&block)
      prev, @scope[:focused_controller_routes] = @scope[:focused_controller_routes], true
      yield
    ensure
      @scope[:focused_controller_routes] = false
    end

    def focused_controller_enabled?
      @scope[:focused_controller_routes]
    end

    def add_route(action, options)
      if focused_controller_enabled?
        super(
          action,
          FocusedController::RouteMapper.new(
            @scope,
            { action: action }.merge(options)
          ).options
        )
      else
        super
      end
    end
  end

  module RouteDispatcherExtensions
    private

    FOCUSED_CONTROLLER = "_controller/"

    def controller_reference(controller_param)
      if controller_param.include?(FOCUSED_CONTROLLER)
        const_name = @controller_class_names[controller_param] ||= controller_param.camelize
        ActiveSupport::Dependencies.constantize(const_name)
      else
        super
      end
    end
  end
end

module ActionDispatch::Routing
  class Mapper
    include FocusedController::RoutingExtensions
  end

  class RouteSet::Dispatcher
    prepend FocusedController::RouteDispatcherExtensions
  end
end
