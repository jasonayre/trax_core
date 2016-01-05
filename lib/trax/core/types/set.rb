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
      end
    end
  end
end
