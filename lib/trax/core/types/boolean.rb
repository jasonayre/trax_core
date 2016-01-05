module Trax
  module Core
    module Types
      class Boolean < ::Trax::Core::Types::ValueObject
        def self.type
          :boolean
        end

        def self.to_schema
          result = super
          result[:values] = [true, false]
        end
      end
    end
  end
end
