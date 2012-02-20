module FocusedController
  class Route
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def call(env)
      name.constantize.call(env)
    end

    alias to_s name
  end
end
