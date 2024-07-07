### Examples
# ProductCategory < Enum
#   define :clothing,    1
#   define :shoes,       2
#   define :accessories, 3
# end
# ProductCategory.keys => [:clothing, :shoes, :accessories]

### Accepts either an integer or the name when setting a value
# ProductCategory.new(1) => #{name: :clothing, :value => 1}
module Trax
  module Core
    module Types
      class Enum < SimpleDelegator
        class_attribute :allow_nil, :raise_on_invalid

        ### Class Methods ###
        def self.define_enum_value(const_name, val=nil, deprecated:false, **attributes, &block)
          name = "#{const_name}".underscore.to_sym
          const_name = name.to_s.camelize
          val = (self._values_hash.length + 1) if val.nil?

          raise ::Trax::Core::Errors::DuplicateEnumValue.new(:klass => self.class.name, :value => const_name) if self === name
          raise ::Trax::Core::Errors::DuplicateEnumValue.new(:klass => self.class.name, :value => val) if self === val

          value_klass_class_attributes = {:tag => name, :value => val, :deprecated => deprecated, :attributes => attributes}
          value_klass = ::Trax::Core::NamedClass.new("#{self.name}::#{const_name}", ::Trax::Core::Types::EnumValue, **value_klass_class_attributes, &block)

          self._values_hash[val] = value_klass
          self._names_hash[name] = value_klass
        end

        def self.[](val)
          find_enum_value(val)
        end

        def self.as_json(options={})
          choice.to_s
        end

        def self.choices
          @choices ||= self._values_hash.values
        end

        def self.formatted_choices
          @formatted_choices ||= choices.each_with_object({}) do |choice, hash|
            hash[choice.to_i] = choice.to_s
          end
        end

        def self.select_values(*args)
          args.flat_compact_uniq!
          args.map{|arg| self[arg].to_i }
        end

        def self.select_enum_values(*args)
          args.flat_compact_uniq!
          args.map{ |arg| find_enum_value(arg) }.compact
        end

        def self.find_enum_value(val)
          if ::Is.numeric?(val)
            self._values_hash[val]
          elsif ::Is.symbolic?(val)
            val = val.to_sym if val.is_a?(::String)
            self._names_hash[val]
          elsif val.superclass.name == "Trax::Core::Types::EnumValue"
            val = val.to_sym
            self._names_hash[val]
          end
        end

        def self.define(*args)
          define_enum_value(*args)
        end

        #define multiple values if its iterable
        def self.define_values(*args)
          args.each_with_index do |arg, i|
            define_enum_value(arg, (i + 1))
          end
        end

        def self.each(&block)
          keys.each(&block)
        end

        def self.each_pair(&block)
          self._names_hash.each_pair(&block)
        end

        def self.keys
          _names_hash.keys
        end

        def self.key?(name)
          _names_hash.key?(name)
        end

        def self.names
          _names_hash.values
        end

        def self.non_deprecated_choices
          choices.reject(&:deprecated?)
        end

        def self.no_raise_mode?
          !raise_on_invalid
        end

        def self.valid_name?(val)
          _names_as_strings.include?(val)
        end

        def self.valid_value?(val)
          values.include?(val)
        end

        #because calling valid_value? in the define_enum_value method is unclear
        def self.value?(val)
          valid_value?(val)
        end

        def self.values
          _names_hash.values.map(&:to_i)
        end

        def self.===(val)
          _names_hash.values.any?{|v| v === val }
        end

        def self.type
          :enum
        end

        ###TODO: after updating hashie version this is now causing the following warning, need to figure out best way to deal with it:
        #You are setting a key that conflicts with a built-in method Trax::Core::Definition#values defined in Hash. This can cause unexpected behavior when accessing the key as a property. You can still access the key via the #[] method.
        def self.to_schema
          result = ::Trax::Core::Definition.new(
            :name => self.name.demodulize.underscore,
            :source => self.name,
            :type => self.type,
            :choices => non_deprecated_choices.map(&:to_schema),
            :values => non_deprecated_choices.map(&:to_sym)
          )
          result[:default] = self.default if self.respond_to?(:default)
          result
        end

        class << self
          alias :enum_value :define_enum_value
          alias :define :define_enum_value
          attr_accessor :_values_hash
          attr_accessor :_names_hash
          attr_accessor :_names_as_strings
        end

        ### Hooks ###
        def self.inherited(subklass)
          super(subklass)

          if self.instance_variable_defined?(:@_values_hash)
            subklass.instance_variable_set(:@_values_hash, ::Hash.new.merge(@_values_hash))
            subklass.instance_variable_set(:@_names_hash, ::Hash.new.merge(@_names_hash))
          else
            subklass.instance_variable_set(:@_values_hash, ::Hash.new)
            subklass.instance_variable_set(:@_names_hash, ::Hash.new)
          end

          subklass.allow_nil = false
          subklass.raise_on_invalid = false
        end

        ### Instance Methods ###
        attr_reader :choice

        def initialize(val)
          self.choice = val unless val.nil? && self.class.allow_nil
        end

        def current_index
          self.class.names.index(choice)
        end

        def choice=(val)
          @choice = valid_choice?(val) ? self.class[val] : nil

          raise ::Trax::Core::Errors::InvalidEnumValue.new(
            :field => self.class.name,
            :value => val
          ) if self.class.raise_on_invalid && !@choice

          @choice
        end

        def __getobj__
          @choice || nil
        end

        def next_value
          return choice if self.class.names.length == current_index
          self.class.names[(current_index + 1)]
        end

        def next_value?
          !(current_index == (self.class.names.length - 1))
        end

        #set choice if next value exists, return selected choi
        def select_next_value
          self.choice = next_value.to_sym if next_value?
          self
        end

        def select_previous_value
          self.choice = previous_value.to_sym if previous_value?
          self
        end

        def previous_value
          self.class.names[(current_index - 1)]
        end

        def previous_value?
          !!current_index
        end

        def to_s
          choice.to_s
        end

        def valid_choice?(val)
          self.class === val
        end
      end
    end
  end
end
