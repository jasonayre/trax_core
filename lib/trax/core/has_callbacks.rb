module Trax
  module Core
    module HasCallbacks
      # extend ::ActiveSupport::Concern

      def self.extended(base) #:nodoc:
        base.class_eval do
          extend ActiveModel::Callbacks
          extend ClassMethods
        end
      end

      # include ::ActiveSupport::Callbacks
      # extend ::ActiveModel::Callbacks


      # extend ::ActiveModel::Callbacks

      # included do
      #   include ::ActiveModel::Callbacks
      # end
      # include ::ActiveModel::Callbacks

      # def self.extended(base)
      #   base.module_attribute(:mixin_registry) { Hash.new }
      #   base.extend(ClassMethods)
      #
      #   base.define_configuration_options! do
      #     option :auto_include, :default => false
      #     option :auto_include_mixins, :default => []
      #   end
      #
      #   mixin_module = base.const_set("Mixin", ::Module.new)
      #   mixin_module.module_attribute(:mixin_namespace) { base }

      module ClassMethods
        # def after(*methods, **options)
        #   options.merge!(:only => [:after])
        #   define_model_callbacks(*methods, **options)
        # end

        def define_model_callbacks(*callbacks, **options)
          super(*callbacks, **options)

          puts "CALLING DEFINE MODEL CALLBACKS"

          callbacks.each do |method_name|
            prepend(::Module.new do
              define_method(method_name) do |*args, **options|
                run_callbacks method_name do
                  self.__smartsuper__(method_name, *args, **options)
                end
              end
            end)
          end
        end

      end
    end

  end
end
