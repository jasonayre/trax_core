module Trax
  module Core
    class Transformer < SimpleDelegator
      include ::Trax::Core::CommonTransformerMethods
      attr_reader :input, :parent, :output

      #if class does not have properties attributes it was an anonymous transformer created by a block,
      #otherwise it was inherited from normally and we dont want to wipe out existing attributes
      def self.inherited(subklass)
        if(subklass.try(:properties))
          apply_duplicated_class_attributes_to_subklass(subklass)
        else
          apply_blank_class_attributes_to_subklass(subklass)
        end
      end

      def self.apply_blank_class_attributes_to_subklass(subklass)
        subklass.class_attribute :properties
        subklass.properties = {}.with_indifferent_access
        subklass.class_attribute :after_initialize_callbacks
        subklass.after_initialize_callbacks = ::Set.new
        subklass.class_attribute :after_transform_callbacks
        subklass.after_transform_callbacks = ::Set.new
      end

      #need to dup the existing class attributes else they will be modified on original
      def self.apply_duplicated_class_attributes_to_subklass(subklass)
        subklass.properties = subklass.properties.dup
        subklass.after_initialize_callbacks = subklass.after_initialize_callbacks.dup
        subklass.after_transform_callbacks = subklass.after_transform_callbacks.dup
      end

      def self.after_initialize(&block)
        after_initialize_callbacks << block
      end

      def self.after_transform(&block)
        after_transform_callbacks << block
      end

      def self.input_properties
        @input_properties ||= properties.values.select{ |prop| prop.is_source_input? }
      end

      def self.computed_properties
        @computed_properties ||= properties.values.reject{ |prop| prop.is_source_input? }
      end

      def self.property(_property_name, **options, &block)
        options[:parent_definition] = self
        options[:property_name] = _property_name
        options[:with] ||= block if block_given?
        options[:from] = options[:property_name] unless options[:from]
        transformer_klass_name = "#{name}::#{_property_name.camelize}"
        transformer_klass = ::Trax::Core::NamedClass.new(transformer_klass_name, TransformerProperty, **options)
        self.properties[_property_name] = transformer_klass
      end

      def self.transformer(_property_name, **options, &block)
        options[:parent_definition] = self
        options[:default] = ->(){ {}.with_indifferent_access } unless options.key?(:default)

        transformer_klass_name = "#{name}::#{_property_name.camelize}Transformer"
        transformer_klass = ::Trax::Core::NamedClass.new(transformer_klass_name, Transformer, **options, &block)
        property_options = {}.merge(options)
        property_options[:with] = transformer_klass
        property(_property_name, **property_options)
      end

      def initialize(obj={}, parent=nil)
        @input = obj.is_a?(::Hash) ? obj.dup : obj
        @output = {}.with_indifferent_access
        @parent = parent if parent

        initialize_output_properties
        run_after_initialize_callbacks if run_after_initialize_callbacks?
        run_after_transform_callbacks if run_after_transform_callbacks?
      end

      def [](_property)
        if _property.include?("/")
          self.dig(*_property.split("/"))
        else
          super(_property)
        end
      end

      def has_parent?
        !!parent
      end

      def parent_key?(k)
        return false unless has_parent?

        parent.key?(k)
      end

      def __getobj__
        @output
      end

      def to_hash
        @to_hash ||= begin
          duplicate_hash = self.__getobj__.dup

          duplicate_hash.each_pair do |k, v|
            if v.is_a?(::Trax::Core::Transformer)
              duplicate_hash[k] = v.__getobj__
            elsif v.is_a?(::Trax::Core::TransformerProperty)
              duplicate_hash[k] = v.__getobj__
            end
          end

          duplicate_hash.compact
        end
      end

      def to_recursive_hash
        @to_recursive_hash ||= begin
          duplicate_hash = self.__getobj__.dup

          self.each_pair do |k, v|
            if v.is_a?(::Trax::Core::Transformer)
              duplicate_hash[k] = v.to_hash
            elsif v.is_a?(::Trax::Core::TransformerProperty)
              duplicate_hash[k] = v.__getobj__
            end
          end

          duplicate_hash.compact
        end
      end

      private

      def initialize_output_properties
        self.class.input_properties.each do |property_klass|
          @output[property_klass.output_key] = property_klass.new(self)
        end

        self.class.computed_properties.each do |property_klass|
          @output[property_klass.output_key] = property_klass.new(self)
        end

        self
      end

      #will not transform output based on callback result
      def run_after_initialize_callbacks
        self.class.after_initialize_callbacks.each do |callback|
          @output.instance_eval(&callback)
        end
      end

      def run_after_initialize_callbacks?
        self.class.after_initialize_callbacks.any?
      end

      #will transform output with return of each callback
      def run_after_transform_callbacks
        self.class.after_transform_callbacks.each do |callback|
          @output = self.instance_exec(@output, &callback)
        end
      end

      def run_after_transform_callbacks?
        self.class.after_transform_callbacks.any?
      end
    end
  end
end
