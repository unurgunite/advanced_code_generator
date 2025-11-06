# frozen_string_literal: true

module CodeGenerator
  class MethodConfig
    attr_reader :name, :visibility, :parameters, :return_value, :generate_random

    def initialize(name, visibility)
      raise ArgumentError, "Method name must be a Symbol or String" unless name.is_a?(Symbol) || name.is_a?(String)
      raise ArgumentError, "Invalid visibility: #{visibility}" unless %i[public private public_class
                                                                         private_class].include?(visibility)

      @name = name.to_sym
      @visibility = visibility
      @parameters = []
      @return_value = nil
      @generate_random = false

      yield self if block_given?
    end

    def required(param_name)
      validate_param_name(param_name)
      parameters << Parameter.new(:required, param_name)
    end

    def optional(param_name, default: nil)
      validate_param_name(param_name)
      parameters << Parameter.new(:optional, param_name, default: default)
    end

    def keyword_required(param_name)
      validate_param_name(param_name)
      parameters << Parameter.new(:keyword_required, param_name)
    end

    def keyword(param_name, default: nil)
      validate_param_name(param_name)
      parameters << Parameter.new(:keyword, param_name, default: default)
    end

    def returns(value)
      self.return_value = value
    end

    def generate(value: true)
      self.generate_random = value
    end

    private

    attr_writer :parameters, :return_value, :generate_random

    def validate_param_name(name)
      raise ArgumentError, "Parameter name must be a Symbol" unless name.is_a?(Symbol)
    end
  end
end
