require 'active_support/all'
require_relative './array'
require_relative './core/ext/module'
require_relative './core/ext/object'
require_relative './core/ext/string'

module Trax
  module Core
    extend ::ActiveSupport::Autoload

    autoload :Configuration
    autoload :EagerAutoloadNamespace
    autoload :Errors
    autoload :FS
  end
end
