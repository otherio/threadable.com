require 'spec_helper'

describe ProcessIncomingEmailWorker do

  it "should find the incoming email record and pass it to covered.process_incoming_email" do
    incoming_email_double = double(:incoming_email)
    expect(IncomingEmail).to receive(:find).with(42).and_return incoming_email_double
    expect(covered).to receive(:process_incoming_email).with incoming_email_double

    instance = described_class.new
    instance.instance_variable_set(:@covered, covered)
    instance.perform!(42)
  end

end
