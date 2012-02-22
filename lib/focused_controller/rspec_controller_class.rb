module FocusedController
  module RSpecControllerClass
    def controller_class
      metadata = self.metadata[:example_group]
      klass    = nil

      until metadata.nil? || klass.respond_to?(:new)
        klass    = metadata[:description_args].first
        metadata = metadata[:example_group]
      end

      klass.respond_to?(:new) ? klass : super
    end
  end
end
