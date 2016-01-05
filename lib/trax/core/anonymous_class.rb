module Trax
  module Core
    class AnonymousClass
      def self.new(_parent_klass=::Object, **options, &block)
        klass = ::Class.new(_parent_klass)

        options.each_pair do |k,v|
          klass.class_attribute k
          klass.__send__("#{k}=", v)
        end unless options.blank?

        klass.class_eval(&block) if block_given?

        klass
      end
    end
  end
end
