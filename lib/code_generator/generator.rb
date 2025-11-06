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

    private

    attr_reader :methods, :class_methods

    def define_instance_methods(klass)
      return unless methods

      methods.each do |method_config|
        return_value = calculate_return_value(method_config)

        case method_config.visibility
        when :public
          klass.define_method(method_config.name) do |*_args, **_kwargs|
            return_value
          end
        when :private
          klass.send(:define_method, method_config.name) do |*_args, **_kwargs|
            return_value
          end
          klass.send(:private, method_config.name)
        end
      end
    end

    def define_class_methods(klass)
      return unless class_methods

      class_methods.each do |method_config|
        return_value = calculate_return_value(method_config)

        case method_config.visibility
        when :public_class
          klass.define_singleton_method(method_config.name) do |*_args, **_kwargs|
            return_value
          end
        when :private_class
          klass.singleton_class.send(:define_method, method_config.name) do |*_args, **_kwargs|
            return_value
          end
          klass.singleton_class.send(:private, method_config.name)
        end
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

    # DSL methods
    def public_method(name, &block)
      method_config = MethodConfig.new(name, :public, &block)
      @methods << method_config
    end

    def private_method(name, &block)
      method_config = MethodConfig.new(name, :private, &block)
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
  end
end
