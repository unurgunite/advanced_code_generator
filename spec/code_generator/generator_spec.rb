# frozen_string_literal: true

RSpec.describe CodeGenerator::Generator do
  it "creates public methods with DSL" do
    generator = CodeGenerator::Generator.new do |g|
      g.public_method :hello do |m|
        m.returns "world"
      end
    end

    klass = generator.build
    obj = klass.new
    expect(obj.hello).to eq "world"
  end

  it "creates private methods with parameters" do
    generator = CodeGenerator::Generator.new do |g|
      g.private_method :calculate do |m|
        m.required :x
        m.optional :y, default: 10
        m.returns Integer
        m.generate value: true
      end
    end

    klass = generator.build
    obj = klass.new
    result = obj.send(:calculate, 5)
    expect(result).to be_an(Integer)
  end
end
