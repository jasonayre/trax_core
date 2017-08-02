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
      end
    end
  end
end
