# spec/code_generator/generator_spec.rb
# frozen_string_literal: true

RSpec.describe CodeGenerator::Generator do
  describe "public methods" do
    it "creates a simple public method" do
      generator = CodeGenerator::Generator.new do |g|
        g.public_method :hello do |m|
          m.returns "world"
        end
      end

      klass = generator.build
      obj = klass.new
      expect(obj.hello).to eq "world"
    end

    it "creates public method with required parameters" do
      generator = CodeGenerator::Generator.new do |g|
        g.public_method :greet do |m|
          m.required :name
          m.returns "Hello"
        end
      end

      klass = generator.build
      obj = klass.new

      # Should accept the parameter
      expect(obj.greet("Alice")).to eq "Hello"

      # Should raise ArgumentError if parameter missing
      expect { obj.greet }.to raise_error(ArgumentError)
    end

    it "creates public method with optional parameters" do
      generator = CodeGenerator::Generator.new do |g|
        g.public_method :greet do |m|
          m.required :name
          m.optional :greeting, default: "Hello"
          m.returns "done"
        end
      end

      klass = generator.build
      obj = klass.new

      expect(obj.greet("Alice")).to eq "done"
      expect(obj.greet("Alice", "Hi")).to eq "done"
    end

    it "creates public method with keyword parameters" do
      generator = CodeGenerator::Generator.new do |g|
        g.public_method :process do |m|
          m.required :id
          m.keyword :format, default: "json"
          m.keyword_required :action
          m.returns true
        end
      end

      klass = generator.build
      obj = klass.new

      expect(obj.process(1, action: :create)).to eq true
      expect(obj.process(1, format: "xml", action: :update)).to eq true

      # Should raise error if required keyword missing
      expect { obj.process(1) }.to raise_error(ArgumentError)
    end
  end

  describe "private methods" do
    it "creates a private method" do
      generator = CodeGenerator::Generator.new do |g|
        g.private_method :secret do |m|
          m.returns 42
        end
      end

      klass = generator.build
      obj = klass.new

      expect(obj.send(:secret)).to eq 42
      expect { obj.secret }.to raise_error(NoMethodError)
    end

    it "creates private method with parameters" do
      generator = CodeGenerator::Generator.new do |g|
        g.private_method :calculate do |m|
          m.required :x
          m.required :y
          m.returns 100
        end
      end

      klass = generator.build
      obj = klass.new

      expect(obj.send(:calculate, 1, 2)).to eq 100
      expect { obj.send(:calculate, 1) }.to raise_error(ArgumentError)
    end
  end

  describe "protected methods" do
    it "creates a protected method" do
      generator = CodeGenerator::Generator.new do |g|
        g.protected_method :internal do |m|
          m.returns "protected"
        end
      end

      klass = generator.build

      # Create a subclass to test protected method access
      subclass = Class.new(klass) do
        def access_protected
          internal
        end
      end

      obj = subclass.new
      expect(obj.access_protected).to eq "protected"
    end
  end

  describe "class methods" do
    it "creates public class method" do
      generator = CodeGenerator::Generator.new do |g|
        g.public_class_method :helper do |m|
          m.returns "class helper"
        end
      end

      klass = generator.build
      expect(klass.helper).to eq "class helper"
    end

    it "creates private class method" do
      generator = CodeGenerator::Generator.new do |g|
        g.private_class_method :internal_class_method do |m|
          m.returns "private class"
        end
      end

      klass = generator.build

      expect(klass.send(:internal_class_method)).to eq "private class"
      expect { klass.internal_class_method }.to raise_error(NoMethodError)
    end
  end

  describe "random generation" do
    it "generates random integers" do
      generator = CodeGenerator::Generator.new do |g|
        g.public_method :random_int do |m|
          m.returns Integer
          m.generate value: true
        end
      end

      klass = generator.build
      obj = klass.new
      result = obj.random_int

      expect(result).to be_an(Integer)
      expect(result).to be > 0
    end

    it "generates random strings" do
      generator = CodeGenerator::Generator.new do |g|
        g.public_method :random_string do |m|
          m.returns String
          m.generate value: true
        end
      end

      klass = generator.build
      obj = klass.new
      result = obj.random_string

      expect(result).to be_a(String)
      expect(result.length).to eq 10
    end

    it "generates random symbols" do
      generator = CodeGenerator::Generator.new do |g|
        g.public_method :random_symbol do |m|
          m.returns Symbol
          m.generate value: true
        end
      end

      klass = generator.build
      obj = klass.new
      result = obj.random_symbol

      expect(result).to be_a(Symbol)
    end
  end

  describe "parameter validation" do
    it "raises error for invalid parameter name" do
      expect do
        CodeGenerator::Generator.new do |g|
          g.public_method :test do |m|
            m.required "string_name" # Should be symbol
          end
        end
      end.to raise_error(ArgumentError, "Parameter name must be a Symbol")
    end

    it "raises error for invalid parameter type" do
      expect do
        CodeGenerator::Parameter.new(:invalid_type, :name)
      end.to raise_error(ArgumentError, "Invalid parameter type: invalid_type")
    end
  end

  describe "visibility validation" do
    it "raises error for invalid visibility" do
      expect do
        CodeGenerator::MethodConfig.new(:test, :invalid_visibility)
      end.to raise_error(ArgumentError, "Invalid visibility: invalid_visibility")
    end
  end
end
