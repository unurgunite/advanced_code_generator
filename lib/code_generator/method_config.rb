# frozen_string_literal: true

module CodeGenerator
  # Represents the configuration for a single method definition.
  #
  # This class encapsulates all the metadata needed to define a method,
  # including its name, visibility, parameters, return value, and generation
  # settings. It's used internally by {CodeGenerator::Generator} to store
  # method configuration data collected through the DSL.
  #
  # @example Method configuration usage
  #   config = CodeGenerator::MethodConfig.new(:calculate, :public) do |m|
  #     m.required :x
  #     m.optional :y, default: 10
  #     m.returns 42
  #   end
  #
  # @see CodeGenerator::Generator
  # @see CodeGenerator::Parameter
  class MethodConfig
    # @return [Symbol] The name of the method to be defined
    attr_reader :name

    # @return [Symbol] The visibility level (:public, :private, :protected, :public_class, :private_class)
    attr_reader :visibility

    # @return [Array<CodeGenerator::Parameter>] List of method parameters
    attr_reader :parameters

    # @return [Object, nil] The value that the method should return
    attr_reader :return_value

    # @return [Boolean] Whether to generate random values for class return types
    attr_reader :generate_random

    # Valid visibility options for method definitions.
    #
    # @return [Array<Symbol>]
    VALID_VISIBILITIES = %i[public private protected public_class private_class].freeze

    # Initializes a new MethodConfig instance.
    #
    # @param name [Symbol, String] The name of the method to configure
    # @param visibility [Symbol] The visibility level (must be one of {VALID_VISIBILITIES})
    # @yield [method_config] Configuration block for method parameters and settings
    # @yieldparam method_config [CodeGenerator::MethodConfig] The current method configuration instance
    # @raise [ArgumentError] If name is not a Symbol/String or visibility is invalid
    #
    # @example
    #   config = CodeGenerator::MethodConfig.new(:my_method, :public) do |m|
    #     m.required :param1
    #     m.returns "result"
    #   end
    def initialize(name, visibility)
      raise ArgumentError, 'Method name must be a Symbol or String' unless name.is_a?(Symbol) || name.is_a?(String)
      raise ArgumentError, "Invalid visibility: #{visibility}" unless VALID_VISIBILITIES.include?(visibility)

      @name = name.to_sym
      @visibility = visibility
      @parameters = []
      @return_value = nil
      @generate_random = false

      yield self if block_given?
    end

    # Adds a required positional parameter to the method.
    #
    # Required parameters must be provided when calling the method.
    #
    # @param param_name [Symbol] The name of the required parameter
    # @return [void]
    # @raise [ArgumentError] If param_name is not a Symbol
    #
    # @example
    #   m.required :user_id
    #   # Generates: def method_name(user_id)
    def required(param_name)
      validate_param_name(param_name)
      parameters << Parameter.new(:required, param_name)
    end

    # Adds an optional positional parameter to the method.
    #
    # Optional parameters have a default value and can be omitted when calling the method.
    #
    # @param param_name [Symbol] The name of the optional parameter
    # @param default [Object] The default value for the parameter (defaults to nil)
    # @return [void]
    # @raise [ArgumentError] If param_name is not a Symbol
    #
    # @example
    #   m.optional :options, default: {}
    #   # Generates: def method_name(options = {})
    def optional(param_name, default: nil)
      validate_param_name(param_name)
      parameters << Parameter.new(:optional, param_name, default: default)
    end

    # Adds a required keyword parameter to the method.
    #
    # Required keyword parameters must be provided as named arguments when calling the method.
    #
    # @param param_name [Symbol] The name of the required keyword parameter
    # @return [void]
    # @raise [ArgumentError] If param_name is not a Symbol
    #
    # @example
    #   m.keyword_required :format
    #   # Generates: def method_name(format:)
    def keyword_required(param_name)
      validate_param_name(param_name)
      parameters << Parameter.new(:keyword_required, param_name)
    end

    # Adds an optional keyword parameter to the method.
    #
    # Optional keyword parameters have a default value and can be omitted when calling the method.
    #
    # @param param_name [Symbol] The name of the optional keyword parameter
    # @param default [Object] The default value for the parameter (defaults to nil)
    # @return [void]
    # @raise [ArgumentError] If param_name is not a Symbol
    #
    # @example
    #   m.keyword :timeout, default: 30
    #   # Generates: def method_name(timeout: 30)
    def keyword(param_name, default: nil)
      validate_param_name(param_name)
      parameters << Parameter.new(:keyword, param_name, default: default)
    end

    # Sets the return value for the method.
    #
    # The method will return this value when called. If combined with {#generate},
    # and the return value is a Class, it will generate random instances of that class.
    #
    # @param value [Object] The value to return from the method
    # @return [Object] The provided value
    #
    # @example
    #   m.returns "success"
    #   m.returns Integer  # Will generate random integers if #generate is true
    def returns(value)
      self.return_value = value
    end

    # Enables random value generation for class return types.
    #
    # When enabled and the return value is a Class (like Integer, String, Symbol),
    # the method will return random instances of that class instead of the class itself.
    #
    # @param value [Boolean] Whether to enable random generation (defaults to true)
    # @return [Boolean] The provided value
    #
    # @example
    #   m.returns Integer
    #   m.generate true
    #   # Method will return random integers like 42891, not the Integer class
    def generate(value: true)
      self.generate_random = value
    end

    private

    # @!attribute [rw] parameters
    #   @return [Array<CodeGenerator::Parameter>]
    attr_writer :parameters

    # @!attribute [rw] return_value
    #   @return [Object, nil]
    attr_writer :return_value

    # @!attribute [rw] generate_random
    #   @return [Boolean]
    attr_writer :generate_random

    # Validates that a parameter name is a Symbol.
    #
    # @param name [Object] The parameter name to validate
    # @raise [ArgumentError] If name is not a Symbol
    # @return [void]
    def validate_param_name(name)
      raise ArgumentError, 'Parameter name must be a Symbol' unless name.is_a?(Symbol)
    end
  end
end
