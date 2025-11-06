# frozen_string_literal: true

require_relative "lib/code_generator/version"

Gem::Specification.new do |spec|
  spec.name = "code_generator"
  spec.version = CodeGenerator::VERSION
  spec.authors = ["unurgunite"]
  spec.email = [""]

  spec.summary = "Code generation tool based on preferences."
  spec.description = "This gem gives an ability to generate code based on preferences. You can use it to skip a boring routine with writing tests, some classes for other purposes or just for fun."
  spec.homepage = "https://github.com/unurgunite/code_generator."
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/unurgunite/code_generator"
  spec.metadata["changelog_uri"] = "https://github.com/unurgunite/code_generator/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
