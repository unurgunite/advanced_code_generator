# lib/code_generator/parameter.rb
# frozen_string_literal: true

module CodeGenerator
  class Parameter
    VALID_TYPES = %i[required optional keyword_required keyword].freeze

    attr_reader :type, :name, :default

    def initialize(type, name, default: nil)
      raise ArgumentError, "Invalid parameter type: #{type}" unless VALID_TYPES.include?(type)
      raise ArgumentError, "Parameter name must be a Symbol" unless name.is_a?(Symbol)

      @type = type
      @name = name
      @default = default
    end

    def to_ruby_param
      case type
      when :required
        name.to_s
      when :optional
        "#{name} = #{default.inspect}"
      when :keyword_required
        "#{name}:"
      when :keyword
        "#{name}: #{default.inspect}"
      end
    end

    def ruby_param_name
      name
    end
  end
end
