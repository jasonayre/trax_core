require "active_support/core_ext/object/try"

module ObjectExtensions
  def __smartsend__(method_name, *args, **options)
    target = method(method_name)
    target.execute_call_strategy(*args, **options)
  end

  def __smartsuper__(method_name, *args, **options)
    target = method(method_name).super_method
    target.execute_call_strategy(*args, **options)
  end

  def as!(h)
    h.to_transformer.call(self)
  end

  # Defines a Configuration Class within a target module namespace, or nested class
  # i.e. configuration_for(::Ecommerce::Cart) will define
  # Ecommerce::Cart::Configuration class, inherited form Trax::Core::Configuration
  # And we can then define specific configuration options, for that class, on that class
  def configuration_for(target, as = :configuration, run_configuration = false, &blk)
    configuration_ivar_name = (as == :configuration) ? :configuration : :"#{as}_configuration"
    configuration_ivar_name_shortcut = (as == :configuration) ? :config : :"#{as}_config"
    target.const_set(configuration_ivar_name.to_s.classify, ::Class.new(::Trax::Core::Configuration))
    configuration_klass = target.const_get(configuration_ivar_name.to_s.classify)
    configuration_klass.source = target
    configurer_method_name = (as == :configuration) ? :configure : :"configure_#{as}"

    target.singleton_class.instance_variable_set("@#{configuration_ivar_name}", configuration_klass.instance_eval(&blk))
    target.define_singleton_method(configuration_ivar_name) do
      return instance_variable_get("@#{configuration_ivar_name}") || detect_in_chain{ instance_variable_get("@#{configuration_ivar_name}") }
    end
    target.singleton_class.__send__(:alias_method, configuration_ivar_name_shortcut, configuration_ivar_name)

    target.define_singleton_method(configurer_method_name) do |&block|
      if block
        return instance_variable_set("@#{configuration_ivar_name}", configuration_klass.new(&block)) if !instance_variable_get("@#{configuration_ivar_name}")
        return instance_variable_get("@#{configuration_ivar_name}").instance_eval(&block)
      else
        return instance_variable_set("@#{configuration_ivar_name}", configuration_klass.new) if !instance_variable_get("@#{configuration_ivar_name}")
        return instance_variable_get("@#{configuration_ivar_name}")
      end
    end

    target.__send__(configurer_method_name) if run_configuration
  end

  def define_configuration_options(as=:configuration, run_configuration = false, &block)
    configuration_for(self, as, run_configuration, &block)
  end

  def define_configuration_options!(as=:configuration, &block)
    define_configuration_options(as, true, &block)
  end

  alias_method :define_configuration, :define_configuration_options
  alias_method :has_configuration, :define_configuration_options
  alias_method :has_configurable_options, :define_configuration_options
  alias_method :has_configurable_options!, :define_configuration_options!

  def remove_instance_variables(*args)
    args.map{ |ivar_name|
      ivar_name = ivar_name.ivar? ? ivar_name : :"@#{ivar_name}"
      remove_instance_variable(ivar_name) if instance_variable_defined?(ivar_name)
    }

    self
  end
  alias_method :reset_instance_variables, :remove_instance_variables

  def set_fully_qualified_constant(const_name, value)
    segs = const_name.split("::")

    raise(::StandardError.new("Set fully qualified constant requires a preexisting namespace to set under")) unless segs.length > 1

    as, on = segs.pop, segs.join("::").constantize
    on.const_set(as, value)
  end

  #following method stolen from abrandoned https://rubygems.org/gems/try_chain
  def try_chain(*symbols)
    return nil if self.nil?

    symbols = symbols.flatten
    symbols.compact!

    symbols.reduce(self) do |result, symbol|
      result = result.try(symbol)
      break nil if result.nil?
      result
    end
  end
end

class Object
  include ObjectExtensions
end
