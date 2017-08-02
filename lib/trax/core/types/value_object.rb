module Trax
  module Core
    module Types
      class ValueObject < SimpleDelegator
        def initialize(val)
          @value = val
        end

        def __getobj__
          @value
        end

        def nil?
          @value.nil?
        end

        def self.symbolic_name
          name.demodulize.underscore.to_sym
        end

        def self.to_sym
          :value
        end

        def self.to_schema
          result = ::Trax::Core::Definition.new(
            :name => self.name.demodulize.underscore,
            :source => self.name,
            :type => self.type
          )
          result[:attributes] = self.attributes if self.respond_to?(:attributes)
          result[:default] = self.default if self.respond_to?(:default)
          result
        end
      end
    end
  end
end
