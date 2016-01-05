module Trax
  module Core
    module Definitions
      def self.extended(base)
        base.extend(Trax::Core::Fields)
      end

      def anonymous_struct(klass_name, **options, &block)
        attribute_klass = if options.key?(:extend)
          _klass_prototype = options[:extend].constantize.clone
          ::Trax::Core::AnonymousClass.new(_klass_prototype, :parent_definition => self, &block)
        else
          ::Trax::Core::AnonymousClass.new(::Trax::Core::Types::AnonymousStruct, :parent_definition => self, &block)
        end

        attribute_klass
      end

      def anonymous_enum(klass_name, **options, &block)
        attribute_klass = if options.key?(:extend)
          _klass_prototype = options[:extend].constantize.clone
          ::Trax::Core::AnonymousClass.new(_klass_prototype, :parent_definition => self, &block)
        else
          ::Trax::Core::AnonymousClass.new(::Trax::Core::Types::AnonymousEnum, :parent_definition => self, &block)
        end

        attribute_klass
      end

      def enum(klass_name, **options, &block)
        attribute_klass = if options.key?(:extend)
          _klass_prototype = options[:extend].constantize.clone
          ::Trax::Core::NamedClass.new("#{self.name}::#{klass_name}", _klass_prototype, :parent_definition => self, &block)
        else
          ::Trax::Core::NamedClass.new("#{self.name}::#{klass_name}", ::Trax::Core::Types::Enum, :parent_definition => self, &block)
        end

        attribute_klass
      end

      def struct(klass_name, **options, &block)
        attribute_klass = if options.key?(:extend)
          _klass_prototype = options[:extend].constantize.clone
          ::Trax::Core::NamedClass.new("#{self.name}::#{klass_name}", _klass_prototype, :parent_definition => self, &block)
        else
          ::Trax::Core::NamedClass.new("#{self.name}::#{klass_name}", ::Trax::Core::Types::Struct, :parent_definition => self, &block)
        end

        attribute_klass
      end
    end
  end
end
