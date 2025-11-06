# frozen_string_literal: true

module CodeGenerator
  # Represents a single method parameter configuration.
  #
  # This class encapsulates the metadata for a method parameter, including
  # its type (required, optional, keyword, etc.), name, and default value.
  # It's used internally by {CodeGenerator::MethodConfig} to store parameter
  # definitions that are later converted to Ruby method signatures.
  #
  # @example Parameter usage
  #   param = CodeGenerator::Parameter.new(:required, :user_id)
  #   param.to_ruby_param # => "user_id"
  #
  # @see CodeGenerator::MethodConfig
  class Parameter
    # Valid parameter types for method definitions.
    #
    # @return [Array<Symbol>]
    VALID_TYPES = %i[required optional keyword_required keyword].freeze

    # @return [Symbol] The type of parameter (:required, :optional, :keyword_required, :keyword)
    attr_reader :type

    # @return [Symbol] The name of the parameter
    attr_reader :name

    # @return [Object, nil] The default value for optional parameters (nil for required parameters)
    attr_reader :default

    # Initializes a new Parameter instance.
    #
    # @param type [Symbol] The parameter type (must be one of {VALID_TYPES})
    # @param name [Symbol] The parameter name
    # @param default [Object, nil] The default value for optional parameters (defaults to nil)
    # @raise [ArgumentError] If type is invalid or name is not a Symbol
    #
    # @example
    #   # Required parameter
    #   param = CodeGenerator::Parameter.new(:required, :id)
    #
    #   # Optional parameter with default
    #   param = CodeGenerator::Parameter.new(:optional, :options, default: {})
    #
    #   # Required keyword parameter
    #   param = CodeGenerator::Parameter.new(:keyword_required, :format)
    #
    #   # Optional keyword parameter
    #   param = CodeGenerator::Parameter.new(:keyword, :timeout, default: 30)
    def initialize(type, name, default: nil)
      raise ArgumentError, "Invalid parameter type: #{type}" unless VALID_TYPES.include?(type)
      raise ArgumentError, 'Parameter name must be a Symbol' unless name.is_a?(Symbol)

      @type = type
      @name = name
      @default = default
    end

    # Converts the parameter configuration to a Ruby method parameter string.
    #
    # This method generates the appropriate Ruby syntax for the parameter
    # based on its type and configuration, which is used when defining
    # methods with {CodeGenerator::Generator}.
    #
    # @return [String] The Ruby parameter string
    #
    # @example
    #   CodeGenerator::Parameter.new(:required, :name).to_ruby_param
    #   # => "name"
    #
    #   CodeGenerator::Parameter.new(:optional, :options, default: {}).to_ruby_param
    #   # => "options = {}"
    #
    #   CodeGenerator::Parameter.new(:keyword_required, :format).to_ruby_param
    #   # => "format:"
    #
    #   CodeGenerator::Parameter.new(:keyword, :timeout, default: 30).to_ruby_param
    #   # => "timeout: 30"
    def to_ruby_param
      case type
      when :required
        name.to_s
      when :optional
        if default.nil?
          "#{name} = nil"
        else
          "#{name} = #{default.inspect}"
        end
      when :keyword_required
        "#{name}:"
      when :keyword
        if default.nil?
          "#{name}: nil"
        else
          "#{name}: #{default.inspect}"
        end
      end
    end

    # Returns the parameter name as a Symbol.
    #
    # This is a convenience method that simply returns the {#name} attribute.
    #
    # @return [Symbol] The parameter name
    #
    # @example
    #   param = CodeGenerator::Parameter.new(:required, :user_id)
    #   param.ruby_param_name # => :user_id
    def ruby_param_name
      name
    end
  end
end
