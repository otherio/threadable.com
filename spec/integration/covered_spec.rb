require 'spec_helper'

describe "covered" do
  it "should work" do

    expect{ Covered.new }.to raise_error ArgumentError, 'required options: :host'

  end
end
