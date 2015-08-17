require 'active_support/all'
require_relative './core/fs'
require_relative './core/ext/array'
require_relative './core/ext/class'
require_relative './core/ext/enumerable'
require_relative './core/ext/module'
require_relative './core/ext/hash'
require_relative './core/ext/object'
require_relative './core/ext/string'
require_relative './core/ext/symbol'
require_relative './core/ext/is'
require_relative './core/primitives/enum_value'
require_relative './core/primitives/enum'

module Trax
  module Core
    extend ::ActiveSupport::Autoload

    autoload :AbstractMethods
    autoload :Configuration
    autoload :Concern
    autoload :Definition
    autoload :EagerLoadNamespace
    autoload :EagerAutoloadNamespace
    autoload :Errors
    autoload :FS
    autoload :HasMixins
    autoload :InheritanceHooks
    autoload :Mixin
    autoload :Mixable
    autoload :TrackableProcEvaluation
  end
end
