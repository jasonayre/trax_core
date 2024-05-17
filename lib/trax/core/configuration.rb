require 'hashie/dash'
require 'active_model'
require 'active_model/validations'

module Trax
  module Core
    class Configuration
      include ActiveModel::Validations

      class_attribute :source

      def self.after_configured(&block)
        self.instance_variable_set("@_after_configured_block", block)
      end

      def self.inherited(subklass)
        super(subklass)

        subklass.class_attribute :options_module
        subklass.options_module = subklass.const_set("Options", ::Module.new)
        subklass.include(subklass.options_module)

        subklass.class_attribute :configurable_options
        subklass.configurable_options = {}
      end

      #the reason for defining the methods in the options module which gets
      #dynamically created is to preserve the inheritance chain
      #so def something= can be overwritten, and call super, an example is in
      #Trax::Model::UniqueId
      #there probably is a cleaner way to do it though.
      def self.option(attr_name, options = {})
        validates_presence_of(attr_name) if(options.key?(:required))
        if(options.key?(:validates))
          validates(attr_name, options[:validates])
        end

        options_module.module_eval do
          attr_reader(attr_name)

          define_method(:"#{attr_name}=") do |val|
            value = options.key?(:setter) ? options[:setter].call(val) : val
            instance_variable_set("@#{attr_name}", value)

            raise_errors unless self.valid?
          end

          if(options.key?(:getter))
            define_method(attr_name) do |val|
              options[:getter].call(val)
            end
          end
        end

        self.configurable_options[attr_name] = options
      end

      def self.klass(&block)
        #so we can properly resolve super lookups, we define new module and include
        mod = ::Module.new
        mod.module_eval(&block)
        include(mod)
      end

      def initialize
        set_default_values

        yield self if block_given?

        raise_errors unless self.valid?

        self.class.instance_variable_get("@_after_configured_block").call(self) if self.class.instance_variable_defined?("@_after_configured_block")
      end

      def compact
        cached_hash.compact
      end

      def cached_hash
        @cached_hash ||= hash
      end

      def hash
        configurable_options.keys.each_with_object({}) do |key, result|
          result[key] =  __send__(key)
        end
      end

      def set_default_values
        self.class.configurable_options.select{|attr_name, hash| hash.key?(:default) }.each_pair do |attr_name, hash|
          parent_context = self.class.module_parent_name.try(:constantize) if self.class.try(:module_parent_name)

          default_value_for_option = if hash[:default].is_a?(Proc)
            hash[:default].arity > 0 ? self.instance_exec(parent_context, &hash[:default])
                                     : self.instance_exec(&hash[:default])
          else
            hash[:default]
          end

          __send__("#{attr_name}=", default_value_for_option)
        end
      end

      def merge!(options = {})
        options.each_pair{ |k,v| __send__("#{k}=", v) }
      end

      def raise_errors
        raise Trax::Core::Errors::ConfigurationError.new(
          :messages => self.errors.full_messages,
          :source => self.class.name
        )
      end
    end
  end
end
