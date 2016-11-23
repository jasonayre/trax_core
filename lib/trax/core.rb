require 'active_support/all'
require 'wannabe_bool'
require_relative './core/fs'
require_relative './core/ext/array'
require_relative './core/ext/class'
require_relative './core/ext/enumerable'
require_relative './core/ext/method'
require_relative './core/ext/module'
require_relative './core/ext/hash'
require_relative './core/ext/object'
require_relative './core/ext/string'
require_relative './core/ext/symbol'
require_relative './core/ext/is'
require_relative './core/ext/uri'
require_relative './core/primitives/enum_value'
require_relative './core/primitives/enum'

if(::RUBY_VERSION < '2.3')
  begin
    require 'ruby_dig'
  rescue LoadError => e
    raise unless e.message =~ /ruby_dig/
    error = e.exception("Trax::Core::Transformer relies on ruby_dig shim, add gem 'ruby_dig' to gemfile")
    error.set_backtrace(e.backtrace)
    raise error
  end
end

module Trax
  module Core
    extend ::ActiveSupport::Autoload

    autoload :AbstractMethods
    autoload :Blueprint

    autoload :Configuration
    autoload :Concern
    autoload :Definition
    autoload :Definitions
    autoload :EagerLoadNamespace
    autoload :EagerAutoloadNamespace
    autoload :Errors
    autoload :Fields
    autoload :FS
    autoload :HasCallbacks     
    autoload :HasMixins
    autoload :HasDependencies
    autoload :InheritanceHooks
    autoload :Mixin
    autoload :Mixable
    autoload :NamedClass
    autoload :NamedModule
    autoload :SilenceWarnings
    autoload :Transformer
    autoload :Types
    autoload :PathPermutations
  end
end
