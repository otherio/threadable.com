require 'spec_helper'

describe Covered::Operations do

  it "should respond to process_incoming_email" do
    expect(covered.operations).to respond_to :process_incoming_email
  end

  describe "[]" do
    it "should return the operation if it exists" do
      expect(Covered::Operations['sdfhdjskfhdjks']).to be_nil
      expect(Covered::Operations['process_incoming_email']).to eq Covered::Operations::ProcessIncomingEmail
    end
  end

end
