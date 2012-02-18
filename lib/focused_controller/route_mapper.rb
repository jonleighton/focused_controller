require 'action_dispatch'

module FocusedController
  class RouteMapper < ActionDispatch::Routing::Mapper
    def initialize(set, scope)
      @set, @scope = set, scope
    end

    def add_route(action, options)
      options = options.dup

      if to = focused_controller_action(action, options)
        options[:to] = FocusedController::Route.new(to)
      end

      super(action, options)
    end

    private

    def focused_controller_action(action, options)
      if options[:to] && !options[:to].respond_to?(:call)
        options[:to]
      elsif action && @scope[:controller]
        name = ''
        name << @scope[:module].camelize << '::' if @scope[:module]
        name << @scope[:controller].camelize << 'Controller::'
        name << action.to_s.camelize
        name
      end
    end
  end

  module MapperExtension
    def focused_controller_routes(&block)
      RouteMapper.new(@set, @scope).instance_eval(&block)
    end
  end

  ActionDispatch::Routing::Mapper.send(:include, MapperExtension)
end
