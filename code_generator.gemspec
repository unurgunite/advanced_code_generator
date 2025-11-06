# frozen_string_literal: true

require_relative 'lib/advanced_code_generator/version'

Gem::Specification.new do |spec|
  spec.name = 'advanced_code_generator'
  spec.version = AdvancedCodeGenerator::VERSION
  spec.authors = ['unurgunite']
  spec.email = ['senpaiguru1488@gmail.com']

  spec.summary = 'Code generation tool based on preferences.'
  spec.description = <<~TEXT
    This gem makes it possible to generate code based on preferences. You can use it to avoid the boring routine of writing tests, use some classes for other purposes, or just for fun.
  TEXT
  spec.homepage = 'https://github.com/unurgunite/advanced_code_generator.'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/unurgunite/advanced_code_generator'
  spec.metadata['changelog_uri'] = 'https://github.com/unurgunite/advanced_code_generator/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.24'
  spec.add_development_dependency 'rubocop-sorted_methods_by_call'
  spec.add_development_dependency 'yard'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
