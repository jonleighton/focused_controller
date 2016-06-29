require "rspec/version"

module FocusedController
  module RSpecControllerClass
    def controller_class
      metadata = self.metadata
      metadata = metadata[:example_group] if RSpec::Version::STRING < "3"
      klass    = nil

      until metadata.nil? || klass.respond_to?(:new)
        klass    = metadata[:description_args].first

        if RSpec::Version::STRING < "3"
          metadata = metadata[:example_group]
        else
          metadata = metadata[:parent_example_group]
        end
      end

      klass.respond_to?(:new) ? klass : super
    end
  end
end
