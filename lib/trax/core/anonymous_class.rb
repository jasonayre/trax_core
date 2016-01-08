module Trax
  module Core
    class AnonymousClass
      class_attribute :registry
      self.registry = {}.with_indifferent_access

      def self.new(_parent_klass=::Object, **options, &block)
        klass = ::Class.new(_parent_klass)

        options.each_pair do |k,v|
          klass.class_attribute k
          klass.__send__("#{k}=", v)
        end unless options.blank?

        klass.class_eval(&block) if block_given?

        registry[klass.registry_key] = klass if klass.respond_to?(:registry_key)

        klass
      end
    end
  end
end
