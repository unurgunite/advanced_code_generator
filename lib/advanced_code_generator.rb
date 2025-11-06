# frozen_string_literal: true

require 'securerandom'
require_relative 'advanced_code_generator/version'
require_relative 'advanced_code_generator/parameter'
require_relative 'advanced_code_generator/method_config'
require_relative 'advanced_code_generator/generator'

module AdvancedCodeGenerator
  class Error < StandardError; end
end
