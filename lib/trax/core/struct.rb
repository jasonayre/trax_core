require 'hashie/extensions/coercion'
require 'hashie/extensions/indifferent_access'
require 'hashie/extensions/dash/indifferent_access'

module Trax
  module Core
    class Struct < ::Hashie::Dash
      include ::Hashie::Extensions::Dash::IndifferentAccess
      include ::Hashie::Extensions::Coercion
      include ::Hashie::Extensions::IgnoreUndeclared
      include ::Hashie::Extensions::Dash::PropertyTranslation
      include ::ActiveModel::Validations

      class_attribute :property_types

      def self.inherited(subklass)
        super(subklass)
      end

      # def self.struct_property(name, *args, **options, &block)
      #   struct_klass_name = "#{name}_structs".classify
      #   struct_klass = const_set(struct_klass_name, ::Class.new(::Trax::Model::Struct))
      #   struct_klass.instance_eval(&block)
      #   options[:default] = {} unless options.key?(:default)
      #   property(name, *args, **options)
      #   coerce_key(name, struct_klass)
      # end
    end
  end
end