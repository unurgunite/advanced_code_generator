# frozen_string_literal: true

require "securerandom"
require_relative "code_generator/version"
require_relative "code_generator/parameter"
require_relative "code_generator/method_config"
require_relative "code_generator/generator"

module CodeGenerator
  class Error < StandardError; end
end
