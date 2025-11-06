Here's a **modern, professional README.md** that reflects your DSL-based code generator:

# CodeGenerator

![Repobeats](https://repobeats.axiom.co/api/embed/cf02cc6438367e8127e0aae8fc871c935844f4e8.svg "Project stats")
[![Gem Version](https://badge.fury.io/rb/code_generator.svg)](https://rubygems.org/gems/code_generator)
[![CI](https://github.com/unurgunite/code_generator/actions/workflows/ci.yml/badge.svg)](https://github.com/unurgunite/code_generator/actions)

**A fluent DSL for generating Ruby classes with stubbed methods for testing and prototyping.**

* [CodeGenerator](#codegenerator)
    * [Features](#features)
    * [Installation](#installation)
    * [Usage Examples](#usage-examples)
        * [Basic Public Method](#basic-public-method)
        * [Method with Parameters](#method-with-parameters)
        * [Private and Protected Methods](#private-and-protected-methods)
        * [Class Methods](#class-methods)
        * [Random Value Generation](#random-value-generation)
    * [Testing](#testing)
    * [Development](#development)
        * [Available Commands](#available-commands)
        * [Release Process](#release-process)
    * [Requirements](#requirements)
    * [Contributing](#contributing)
    * [License](#license)
    * [Code of Conduct](#code-of-conduct)

## Features

- **Fluent DSL**: Clean, readable syntax for defining methods
- **Full visibility support**: Public, private, and protected instance methods
- **Class method support**: Public and private class methods
- **Parameter configuration**: Define required, optional, and keyword parameters
- **Smart return values**: Return specific objects or generate random values
- **Zero dependencies**: Pure Ruby, no external requirements

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'code_generator'
```

And then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install code_generator
```

## Usage Examples

### Basic Public Method

```ruby
generator = CodeGenerator::Generator.new do |g|
  g.public_method :hello do |m|
    m.returns "world"
  end
end

Klass = generator.build
obj = Klass.new
obj.hello # => "world"
```

### Method with Parameters

```ruby
generator = CodeGenerator::Generator.new do |g|
  g.public_method :greet do |m|
    m.required :name
    m.optional :greeting, default: "Hello"
    m.keyword_required :format
    m.returns true
  end
end

Klass = generator.build
obj = Klass.new
obj.greet("Alice", format: :json) # => true
obj.greet("Bob", "Hi", format: :xml) # => true
```

### Private and Protected Methods

```ruby
generator = CodeGenerator::Generator.new do |g|
  g.private_method :secret_calculation do |m|
    m.returns 42
  end

  g.protected_method :internal_logic do |m|
    m.returns "protected result"
  end
end

Klass = generator.build
obj = Klass.new
obj.send(:secret_calculation) # => 42
# obj.secret_calculation                    # => NoMethodError

# Protected method access through subclass
Subclass = Class.new(Klass) do
  def access_protected
    internal_logic
  end
end
Subclass.new.access_protected # => "protected result"
```

### Class Methods

```ruby
generator = CodeGenerator::Generator.new do |g|
  g.public_class_method :factory do |m|
    m.returns "class helper"
  end

  g.private_class_method :setup do |m|
    m.returns "private setup"
  end
end

Klass = generator.build
Klass.factory # => "class helper"
Klass.send(:setup) # => "private setup"
```

### Random Value Generation

```ruby
generator = CodeGenerator::Generator.new do |g|
  g.public_method :random_int do |m|
    m.returns Integer
    m.generate true
  end

  g.public_method :random_string do |m|
    m.returns String
    m.generate true
  end
end

Klass = generator.build
obj = Klass.new
obj.random_int # => 42891 (random integer)
obj.random_string # => "aB3xY9zK2m" (random string)
```

## Testing

Run the test suite:

```bash
bundle exec rspec
```

## Development

After checking out the repo, run:

```bash
bin/setup
```

This will install dependencies and start an interactive console.

### Available Commands

- `bin/console` - Interactive development console
- `bin/setup` - Install dependencies and build gem
- `bundle exec rake` - Run tests and linting

### Release Process

1. Update version in `lib/code_generator/version.rb`
2. Create and push a git tag: `git tag v0.1.0 && git push origin v0.1.0`
3. GitHub Actions will automatically:
    - Build the gem
    - Publish to RubyGems.org
    - Create a GitHub release

## Requirements

- **Ruby**: >= 2.6.0
- **No external dependencies**

## Contributing

Bug reports and pull requests are welcome! Please follow these guidelines:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a pull request

Please ensure your code passes all tests and follows the existing style.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting with this project is expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

---

> **Note**: This gem is designed for **testing and prototyping**. Generated methods accept any parameters and return
> configured values, making it perfect for creating test doubles and stubs.

```
