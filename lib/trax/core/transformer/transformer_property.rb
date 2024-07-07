module Trax
  module Core
    class TransformerProperty < SimpleDelegator
      include ::Trax::Core::CommonTransformerMethods

      def initialize(transformer)
        @transformer = transformer
        set_value

        transform_value_with_block if self.class.is_callable?
        transform_value if self.class.has_transformer_class?
        set_default_value if set_default_value?
      end

      def nil?
        __getobj__.nil?
      end

      def __getobj__
        @value.is_a?(::Trax::Core::Transformer) ? @value.__getobj__ : @value
      end

      def value
        @value
      end

      protected

      def default_property_value
        if self.class.default.is_a?(Proc)
          self.class.default.arity > 0 ? self.class.default.call(@transformer) : self.class.default.call
        else
          self.class.default
        end
      end

      def fetch_property_value
        if self.class.from_parent?
          fetch_property_value_from_parent
        else
          self.target.dig(*self.class.input_key_chain)
        end
      end

      def fetch_property_value_from_parent
        if self.class.from_parent == true
          self.target.dig(self.class.property_name)
        else
          self.target.dig(*self.class.input_key_chain)
        end
      end

      def set_value
        @value = fetch_property_value
      end

      def set_default_value
        @value = default_property_value
      end

      def set_default_value?
        @value.nil? && self.class.has_default_value?
      end

      def target
        @target ||= if self.class.has_transformer_class?
          @transformer.input
        elsif self.class.from_parent?
          @transformer.parent.input
        elsif self.class.is_source_output?
          @transformer.output
        else
          @transformer.input
        end
      end

      def transform_value_with_block
        @value = self.class._with.arity > 1 ? self.class._with.call(@value, @transformer) : self.class._with.call(@value)
      end

      def transform_value
        @value = {} unless @value
        @value = self.class._with.new(@value, @transformer)
      end
    end
  end
end
