# frozen_string_literal: true

module CodeGenerator
  # Generates Ruby classes with stubbed methods using a fluent DSL.
  #
  # This class provides a domain-specific language (DSL) for defining
  # methods with various visibility levels, parameters, and return values.
  # It's primarily designed for testing and prototyping scenarios where
  # you need to create mock objects or stub classes quickly.
  #
  # @example Basic usage
  #   generator = CodeGenerator::Generator.new do |g|
  #     g.public_method :hello do |m|
  #       m.returns "world"
  #     end
  #   end
  #   Klass = generator.build
  #   obj = Klass.new
  #   obj.hello # => "world"
  #
  # @example Method with parameters
  #   generator = CodeGenerator::Generator.new do |g|
  #     g.public_method :greet do |m|
  #       m.required :name
  #       m.optional :greeting, default: "Hello"
  #       m.returns true
  #     end
  #   end
  class Generator
    # @return [Array<CodeGenerator::MethodConfig>] List of instance method configurations
    attr_reader :methods

    # @return [Array<CodeGenerator::MethodConfig>] List of class method configurations
    attr_reader :class_methods

    # Initializes a new Generator instance with empty method collections.
    #
    # This constructor is typically called internally by {Generator.new}
    # and should not be called directly in most cases.
    #
    # @return [void]
    def initialize
      @methods = []
      @class_methods = []
    end

    # Creates a new Generator instance and evaluates the given block in its context.
    #
    # This is the primary entry point for using the DSL. The block parameter
    # provides access to the generator's DSL methods for defining methods.
    #
    # @yield [generator] The generator instance for DSL configuration
    # @yieldparam generator [CodeGenerator::Generator] The current generator instance
    # @return [CodeGenerator::Generator] A configured generator instance
    #
    # @example
    #   generator = CodeGenerator::Generator.new do |g|
    #     g.public_method :test_method do |m|
    #       m.returns "test"
    #     end
    #   end
    def self.new(&block)
      generator = allocate
      generator.__send__(:initialize)
      generator.instance_eval(&block) if block
      generator
    end

    # Builds and returns a new Ruby class with all configured methods defined.
    #
    # This method creates an anonymous class and defines all the methods
    # that were configured through the DSL. The returned class can be
    # instantiated and used like any other Ruby class.
    #
    # @return [Class] A new class with all configured methods
    #
    # @example
    #   generator = CodeGenerator::Generator.new do |g|
    #     g.public_method :hello do |m|
    #       m.returns "world"
    #     end
    #   end
    #   Klass = generator.build
    #   obj = Klass.new
    #   puts obj.hello # => "world"
    def build
      klass = Class.new
      define_instance_methods(klass)
      define_class_methods(klass)
      klass
    end

    # Defines a public instance method on the generated class.
    #
    # @param name [Symbol, String] The name of the method to define
    # @yield [method_config] Configuration block for the method
    # @yieldparam method_config [CodeGenerator::MethodConfig] Method configuration object
    # @return [void]
    #
    # @example
    #   g.public_method :calculate do |m|
    #     m.required :x
    #     m.optional :y, default: 10
    #     m.returns 42
    #   end
    def public_method(name, &block)
      method_config = MethodConfig.new(name, :public, &block)
      @methods << method_config
    end

    # Defines a private instance method on the generated class.
    #
    # Private methods can only be called within the class or its instances
    # using {Object#send} or from within other instance methods.
    #
    # @param name [Symbol, String] The name of the method to define
    # @yield [method_config] Configuration block for the method
    # @yieldparam method_config [CodeGenerator::MethodConfig] Method configuration object
    # @return [void]
    #
    # @example
    #   g.private_method :internal_calculation do |m|
    #     m.returns "private result"
    #   end
    def private_method(name, &block)
      method_config = MethodConfig.new(name, :private, &block)
      @methods << method_config
    end

    # Defines a protected instance method on the generated class.
    #
    # Protected methods can be called by instances of the same class
    # or its subclasses, but not from outside the inheritance hierarchy.
    #
    # @param name [Symbol, String] The name of the method to define
    # @yield [method_config] Configuration block for the method
    # @yieldparam method_config [CodeGenerator::MethodConfig] Method configuration object
    # @return [void]
    #
    # @example
    #   g.protected_method :shared_logic do |m|
    #     m.returns "protected result"
    #   end
    def protected_method(name, &block)
      method_config = MethodConfig.new(name, :protected, &block)
      @methods << method_config
    end

    # Defines a public class method on the generated class.
    #
    # Class methods are called on the class itself rather than instances.
    #
    # @param name [Symbol, String] The name of the method to define
    # @yield [method_config] Configuration block for the method
    # @yieldparam method_config [CodeGenerator::MethodConfig] Method configuration object
    # @return [void]
    #
    # @example
    #   g.public_class_method :factory do |m|
    #     m.returns "class helper"
    #   end
    def public_class_method(name, &block)
      method_config = MethodConfig.new(name, :public_class, &block)
      @class_methods << method_config
    end

    # Defines a private class method on the generated class.
    #
    # Private class methods can only be called within the class context
    # using {Object#send} on the class itself.
    #
    # @param name [Symbol, String] The name of the method to define
    # @yield [method_config] Configuration block for the method
    # @yieldparam method_config [CodeGenerator::MethodConfig] Method configuration object
    # @return [void]
    #
    # @example
    #   g.private_class_method :internal_setup do |m|
    #     m.returns "private setup"
    #   end
    def private_class_method(name, &block)
      method_config = MethodConfig.new(name, :private_class, &block)
      @class_methods << method_config
    end

    private

    # Defines all configured instance methods on the target class.
    #
    # @param klass [Class] The class to define methods on
    # @return [void]
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

    # Defines all configured class methods on the target class.
    #
    # @param klass [Class] The class to define class methods on
    # @return [void]
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

    # Defines a single method on the target class with proper parameter handling.
    #
    # This method handles both simple methods (no parameters) and complex
    # methods (with parameter definitions) by either using define_method
    # with a proc or generating a method definition string with class_eval.
    #
    # @param target_class [Class, #singleton_class] The class to define the method on
    # @param method_config [CodeGenerator::MethodConfig] The method configuration
    # @param define_method_name [Symbol] The method used to define methods (:define_method)
    # @return [void]
    def define_method_with_params(target_class, method_config, define_method_name)
      if method_config.parameters.empty?
        return_value = calculate_return_value(method_config)
        target_class.send(define_method_name, method_config.name) do |*_args, **_kwargs|
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

    # Calculates the actual return value for a method configuration.
    #
    # Handles both static return values and random object generation
    # based on the method configuration settings.
    #
    # @param method_config [CodeGenerator::MethodConfig] The method configuration
    # @return [Object, nil] The calculated return value
    def calculate_return_value(method_config)
      if method_config.generate_random && method_config.return_value.is_a?(Class)
        generate_random_object(method_config.return_value)
      else
        method_config.return_value
      end
    end

    # Generates a random object of the specified class type.
    #
    # Supports Integer, String, and Symbol types with appropriate
    # random generation logic. For unsupported classes, returns
    # the class itself.
    #
    # @param klass [Class] The class to generate a random instance of
    # @return [Object] A random object of the specified type, or the class itself
    #
    # @example
    #   generate_random_object(Integer) # => 42891
    #   generate_random_object(String)  # => "aB3xY9zK2m"
    #   generate_random_object(Symbol)  # => :random_symbol
    #   generate_random_object(Object)  # => Object
    def generate_random_object(klass)
      case klass.name
      when 'Integer'
        rand(1..1_000_000)
      when 'String'
        SecureRandom.alphanumeric(10)
      when 'Symbol'
        SecureRandom.alphanumeric(10).to_sym
      else
        klass
      end
    end
  end
end
