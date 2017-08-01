module Trax
  module Core
    module Types
      class Set < ::Trax::Core::Types::ValueObject
        def initialize(*args)
          super(::Set[*args.flatten])
        end

        def self.type
          :set
        end

        def self.contains_instances_of(klass)
          self.include ::Trax::Core::Types::Behaviors::SetOfMembers
          self.member_class = klass
        end

        def self.of(klass)
          return ::Class.new(self) do
            include ::Trax::Core::Types::Behaviors::SetOfMembers
            self.member_class = klass
            self
          end
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
