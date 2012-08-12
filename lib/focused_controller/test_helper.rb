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

    def url_for(options = nil)
      if options.is_a?(StubbedURL)
        options
      else
        super
      end
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

  class StubbedURL
    attr_reader :helper_name, :args

    def initialize(helper_name, args)
      @helper_name = helper_name.to_s
      @args        = args
    end

    def ==(other)
      other.is_a?(self.class) &&
        helper_name == other.helper_name &&
        args        == other.args
    end

    # Deals with _compute_redirect_to_location in action_controller/metal/redirecting
    # (I don't feel proud about this...)
    def gsub(*)
      self
    end

    def to_s
      "#{helper_name}(#{args.each(&:to_s).join(', ')})"
    end
  end

  module TestHelper
    extend ActiveSupport::Concern
    include ActionDispatch::Assertions::ResponseAssertions

    included do
      class_attribute :_controller_class, :instance_reader => false, :instance_writer => false
    end

    module ClassMethods
      def controller_class=(klass)
        self._controller_class = klass
      end

      def controller_class
        _controller_class || name.sub(/Test$/, '').constantize
      end

      def include_routes
        if controller_class.respond_to?(:_routes) && controller_class._routes
          include controller_class._routes.named_routes.module
        end
      end

      def stub_url(*names)
        setup { stub_url(*names) }
      end
    end

    def controller
      @controller ||= begin
        controller = self.class.controller_class.new
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

    def respond_to?(*args)
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

    def stub_url(*names)
      [self, controller].each do |host|
        host.singleton_class.class_eval do
          names.each do |name|
            define_method("#{name}_url") do |*args|
              StubbedURL.new("#{name}_url", args)
            end

            define_method("#{name}_path") do |*args|
              StubbedURL.new("#{name}_path", args)
            end
          end
        end
      end
    end
  end
end
