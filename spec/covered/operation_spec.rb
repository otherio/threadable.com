require 'spec_helper'

describe Covered::Operation do

  subject(:operation) do
    Class.new(described_class) do
      def call
        self
      end
    end
  end

  it "should include Let" do
    expect(subject).to include Let
  end

  describe "new" do
    it "should be private" do
      expect{ subject.new }.to raise_error NoMethodError
    end
  end

  describe "call" do
    it "should instantiate a new instance, set options and call perform" do
      expect{ operation.call }.to raise_error ArgumentError, "covered is a required option for #{operation}"

      instance = operation.call(covered: covered)
      expect(instance).to be_a operation
      expect(instance.covered).to eq covered

      expect{ operation.call(covered: covered, something: 'else') }.to raise_error ArgumentError, 'unknown options {"something"=>"else"}'
    end
  end

end
