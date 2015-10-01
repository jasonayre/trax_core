module Trax
  module Core
    module Types
      extend ::ActiveSupport::Autoload

      autoload :Array
      autoload :Boolean
      autoload :Enum
      autoload :EnumValue
      autoload :Float
      autoload :Integer
      autoload :Struct
      autoload :String
      autoload :ValueObject
    end
  end
end
