require 'hashie/extensions/coercion'
require 'hashie/extensions/indifferent_access'
require 'hashie/extensions/dash/indifferent_access'

module Trax
  module Core
    module Types
      class AnonymousStruct < ::Hashie::Dash
        include ::Hashie::Extensions::Dash::IndifferentAccess
        include ::Hashie::Extensions::Coercion
        include ::Hashie::Extensions::IgnoreUndeclared
        include ::Hashie::Extensions::Dash::PropertyTranslation

        # note that we must explicitly set default or blank values for all properties.
        # It defeats the whole purpose of being a 'struct'
        # if we fail to do so, and it makes our data far more error prone
        DEFAULT_VALUES_FOR_PROPERTY_TYPES = {
          :anonymous_enum   => nil,
          :anonymous_struct => {},
          :array            => [],
          :array_of         => [],
          :boolean          => nil,
          :enum             => nil,
          :float            => 0.0,
          :integer          => nil,
          :json             => {},
          :string           => "",
          :struct           => {},
          :time             => nil
        }.with_indifferent_access.freeze

        def self.fields_module
          @fields_module ||= begin
            mod = self.const_set("Fields", ::Trax::Core::Fields.clone)
            mod.include(superclass.fields) if superclass.instance_variable_defined?("@fields_module")
            mod
          end
        end

        def self.fields
          fields_module
        end

        def self.anonymous_enum_property(name, *args, **options, &block)
          define_attribute_class_for_type(:anonymous_enum, name, *args, :coerce => true, **options, &block)
        end

        def self.anonymous_struct_property(name, *args, **options, &block)
          define_attribute_class_for_type(:anonymous_struct, name, *args, :coerce => true, **options, &block)
        end

        def self.array_property(name, *args, of:false, **options, &block)
          of_object = of && of.is_a?(::String) ? const_get(of) : of
          coercer = of_object ? of : ::Array
          options.merge!(:member_class => of_object) if of
          array_or_array_of = of ? :array_of : :array
          define_attribute_class_for_type(array_or_array_of, name, *args, :coerce => coercer, **options, &block)
        end

        def self.boolean_property(name, *args, **options, &block)
          define_attribute_class_for_type(:boolean, name, *args, :coerce => ->(value){
            [true, false].include?(value) ? value : value.to_b
          }, **options, &block)
        end

        def self.enum_property(name, *args, **options, &block)
          define_attribute_class_for_type(:enum, name, *args, :coerce => true, **options, &block)
        end

        def self.float_property(name, *args, **options, &block)
          define_attribute_class_for_type(:float, name, *args, :coerce => ::Float, **options, &block)
        end

        def self.integer_property(name, *args, **options, &block)
          define_attribute_class_for_type(:integer, name, *args, :coerce => ::Integer, **options, &block)
        end

        def self.json_property(name, *args, **options, &block)
          define_attribute_class_for_type(:json, name, *args, **options, &block)
        end

        def self.set_property(name, *args, **options, &block)
          define_attribute_class_for_type(:set, name, *args, :coerce => true, **options, &block)
        end

        def self.string_property(name, *args, **options, &block)
          define_attribute_class_for_type(:string, name, *args, :coerce => ::String, **options, &block)
        end

        def self.struct_property(name, *args, **options, &block)
          define_attribute_class_for_type(:struct, name, *args, :coerce => true, **options, &block)
        end

        def self.time_property(name, *args, **options, &block)
          define_attribute_class_for_type(:time, name, *args, :coerce => ->(value){
            result = if value
              case value
              when ::String
                ::Time.parse(value)
              when ::Time
                value
              when ::Proc
                value.call
              end
            end

            result
          }, **options, &block)
        end

        def self.to_schema
          ::Trax::Core::Definition.new(
            :source => self.name,
            :name => self.name.demodulize.underscore,
            :type => :struct,
            :fields => self.fields_module.to_schema
          )
        end

        def self.type; :anonymous_struct end;

        def to_serializable_hash
          _serializable_hash = to_hash

          self.class.fields_module.enums.keys.each do |attribute_name|
            _serializable_hash[attribute_name] = _serializable_hash[attribute_name].try(:to_i)
          end if self.class.fields_module.enums.keys.any?

          _serializable_hash
        end

        class << self
          alias :array :array_property
          alias :anonymous_enum :anonymous_enum_property
          alias :anonymous_struct :anonymous_struct_property
          alias :boolean :boolean_property
          alias :enum :enum_property
          alias :float :float_property
          alias :integer :integer_property
          alias :json :json_property
          alias :set :set_property
          alias :string :string_property
          alias :struct :struct_property
          alias :time :time_property
        end

        def value
          self
        end

        private

        def self._classified_type_name(type_name)
          type_name = "anonymous_#{type_name}" if anonymous_types = [ "enum", "struct" ].include?(type_name.to_s)
          type_name.to_s.classify
        end

        #By default, strings/int/bool wont get cast to value objects
        #mainly for the sake of performance/avoid unneccessary object allocation
        def self.define_attribute_class_for_type(type_name, property_name, *args, coerce:false, **options, &block)
          attribute_klass = if options.key?(:extend)
            _klass_prototype = options[:extend].is_a?(::String) ? options[:extend].safe_constantize : options[:extend]
            _klass = fields_module.const_set(property_name.to_s.classify, ::Trax::Core::AnonymousClass.new(_klass_prototype, &block))
            _klass
          else
            classified_type_name = _classified_type_name(type_name)
            fields_module.const_set(property_name.to_s.classify, ::Trax::Core::AnonymousClass.new("::Trax::Core::Types::#{classified_type_name}".constantize, :parent_definition => self, **options, &block))
          end

          options[:default] = options.key?(:default) ? options[:default] : DEFAULT_VALUES_FOR_PROPERTY_TYPES[type_name]
          property(property_name.to_sym, *args, **options)

          if coerce.is_a?(::Proc)
            coerce_key(property_name.to_sym, coerce)
          elsif coerce.is_a?(::Array)
            coerce_key(property_name.to_sym, coerce)
          elsif [ ::Integer, ::Float, ::String ].include?(coerce)
            coerce_key(property_name.to_sym, coerce)
          elsif coerce
            coerce_key(property_name.to_sym, attribute_klass)
          end
        end
      end
    end
  end
end