require 'action_dispatch'
require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_support/hash_with_indifferent_access'

module FocusedController
  module TestHooks
    attr_reader :_render_options

    def render_to_body(options = {})
      _process_options(options)
      @_render_options = options
    end
  end

  class TestRequest < ActionDispatch::TestRequest
    def initialize(env = {})
      super
      self.session = HashWithIndifferentAccess.new
    end

    def cookie_jar
      @cookie_jar ||= ActionDispatch::Cookies::CookieJar.new
    end

    def flash
      session['flash'] ||= ActionDispatch::Flash::FlashHash.new
    end
  end

  class TestResponse < ActionDispatch::TestResponse
  end

  module TestHelper
    extend ActiveSupport::Concern
    include ActionDispatch::Assertions::ResponseAssertions

    included do
      class_attribute :_controller, :instance_reader => false, :instance_writer => false
    end

    module ClassMethods
      def controller=(klass)
        self._controller = klass
      end

      def controller
        _controller || name.sub(/Test$/, '').constantize
      end

      def include_routes
        if controller.respond_to?(:_routes) && controller._routes
          include controller._routes.named_routes.module
        end
      end
    end

    def controller
      @controller ||= begin
        controller = self.class.controller.new
        controller.singleton_class.send :include, TestHooks
        controller.request  = request
        controller.response = response
        controller
      end
    end

    def request
      @request ||= TestRequest.new
    end

    def response
      @response ||= TestResponse.new
    end

    def req(params = nil, session = nil, flash = nil)
      controller.params = params        if params
      controller.session.update session if session
      controller.flash.update flash     if flash
      controller.run
    end

    def session
      controller.session
    end

    def flash
      controller.flash
    end

    def cookies
      request.cookie_jar
    end

    def assert_template(template, message = nil)
      assert_equal template.to_s, controller._render_options[:template], message
    end

    def assert_response(type, message = nil)
      controller # make sure controller is initialized
      super
    end

    def assert_redirected_to(location, message = nil)
      controller # make sure controller is initialized
      super
    end

    def url_for(*args)
      controller.url_for(*args)
    end

    def _routes_included?
    end

    def respond_to?(method_name)
      unless defined?(@_routes_included) && @_routes_included
        self.class.include_routes
        @_routes_included = true
      end

      super
    end

    def method_missing(method_name, *args, &block)
      if respond_to?(method_name)
        send(method_name, *args, &block)
      else
        super
      end
    end
  end
end
