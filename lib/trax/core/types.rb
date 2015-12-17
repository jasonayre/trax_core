module Trax
  module Core
    module Types
      extend ::ActiveSupport::Autoload

      autoload :AnonymousStruct
      autoload :AnonymousEnum
      autoload :Array
      autoload :ArrayOf
      autoload :Behaviors
      autoload :Boolean
      autoload :Enum
      autoload :EnumValue
      autoload :Float
      autoload :Integer
      autoload :Json
      autoload :String
      autoload :Struct
      autoload :Time
      autoload :ValueObject
    end
  end
end
