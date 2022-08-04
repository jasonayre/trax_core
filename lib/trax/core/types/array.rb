module Trax
  module Core
    module Types
      class Array < ::Trax::Core::Types::ValueObject
        def self.type
          :array
        end

        def self.contains_instances_of(klass)
          self.include ::Trax::Core::Types::Behaviors::ArrayOfMembers
          self.member_class = klass
        end

        def self.is_enumerable?
          true
        end

        def self.of(klass)
          return ::Class.new(self) do
            include ::Trax::Core::Types::Behaviors::ArrayOfMembers
            self.member_class = klass
            self
          end
        end
      end
    end
  end
end
