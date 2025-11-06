# lib/code_generator/generator.rb
# frozen_string_literal: true

module CodeGenerator
  class Generator
    def initialize
      @methods = []
      @class_methods = []
    end

    def self.new(&block)
      generator = allocate
      generator.__send__(:initialize)
      generator.instance_eval(&block) if block
      generator
    end

    def build
      klass = Class.new
      define_instance_methods(klass)
      define_class_methods(klass)
      klass
    end

    def public_method(name, &block)
      method_config = MethodConfig.new(name, :public, &block)
      @methods << method_config
    end

    def private_method(name, &block)
      method_config = MethodConfig.new(name, :private, &block)
      @methods << method_config
    end

    def protected_method(name, &block)
      method_config = MethodConfig.new(name, :protected, &block)
      @methods << method_config
    end

    def public_class_method(name, &block)
      method_config = MethodConfig.new(name, :public_class, &block)
      @class_methods << method_config
    end

    def private_class_method(name, &block)
      method_config = MethodConfig.new(name, :private_class, &block)
      @class_methods << method_config
    end

    private

    attr_reader :methods, :class_methods

    def define_instance_methods(klass)
      return unless @methods

      @methods.each do |method_config|
        case method_config.visibility
        when :public
          define_method_with_params(klass, method_config, :define_method)
        when :private
          define_method_with_params(klass, method_config, :define_method)
          klass.send(:private, method_config.name)
        when :protected
          define_method_with_params(klass, method_config, :define_method)
          klass.send(:protected, method_config.name)
        end
      end
    end

    def define_class_methods(klass)
      return unless class_methods

      class_methods.each do |method_config|
        case method_config.visibility
        when :public_class
          define_method_with_params(klass.singleton_class, method_config, :define_method)
        when :private_class
          define_method_with_params(klass.singleton_class, method_config, :define_method)
          klass.singleton_class.send(:private, method_config.name)
        end
      end
    end

    # lib/code_generator/generator.rb
    def define_method_with_params(target_class, method_config, define_method_name)
      if method_config.parameters.empty?
        return_value = calculate_return_value(method_config)
        target_class.send(define_method_name, method_config.name) do |*args, **kwargs, &block|
          return_value
        end
      else
        # Generate actual method with proper parameter validation
        param_string = method_config.parameters.map(&:to_ruby_param).join(', ')
        return_value = calculate_return_value(method_config)

        # Create the method definition as a string
        method_code = "def #{method_config.name}(#{param_string}); #{return_value.inspect}; end"

        # Evaluate it in the target class context
        target_class.class_eval(method_code)
      end
    end

    def calculate_return_value(method_config)
      if method_config.generate_random && method_config.return_value.is_a?(Class)
        generate_random_object(method_config.return_value)
      else
        method_config.return_value
      end
    end

    def generate_random_object(klass)
      case klass.name
      when "Integer"
        rand(1..1_000_000)
      when "String"
        SecureRandom.alphanumeric(10)
      when "Symbol"
        SecureRandom.alphanumeric(10).to_sym
      else
        klass
      end
    end
  end
end
