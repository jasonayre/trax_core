module Trax
  module Core
    module CommonTransformerMethods
      extend ::ActiveSupport::Concern

      module ClassMethods
        def from_parent?
          return @from_parent if defined?(@from_parent)
          @from_parent = !!try(:from_parent)
        end

        def is_nested?
          return @is_nested if defined?(@is_nested)
          @is_nested = !!try(:parent_definition)
        end

        def is_translated?
          return @is_translated if defined?(@is_translated)
          @is_translated = !!try(:from)
        end

        def is_callable?
          return @is_callable if defined?(@is_callable)
          @is_callable = try(:_with) && try(:_with).is_a?(Proc)
        end

        def is_transformer?
          return @is_transformer if defined?(@is_transformer)
          @is_transformer = ancestors.include?(::Trax::Core::Transformer)
        end

        def is_source_output?
          return @is_source_output if defined?(@is_source_output)
          @is_source_output = (try(:source) && try(:source) == :output) || false
        end

        def input_key_chain
          @input_key_chain ||= input_key.split("/")
        end

        def input_key
          @input_key ||= self.try(:from_parent) || self.try(:from) || self.property_name
        end

        def is_source_input?
          return @is_source_input if defined?(@is_source_input)
          @is_source_input = !is_source_output?
        end

        def has_default_value?
          return @has_default_value if defined?(@has_default_value)
          @has_default_value = !!try(:default)
        end

        def has_transformer_class?
          return @has_transformer_class if defined?(@has_transformer_class)
          @has_transformer_class = try(:_with) && !self._with.is_a?(Proc) && self._with.ancestors.include?(::Trax::Core::Transformer)
        end

        def output_key
          @output_key ||= try(:as) ? as : property_name
        end
      end
    end
  end
end
