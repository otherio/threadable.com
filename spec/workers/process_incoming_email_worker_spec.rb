require 'spec_helper'

describe ProcessIncomingEmailWorker do

  subject{ described_class.new }
  before do
    subject.instance_variable_set(:@covered, covered)
  end
  delegate :perform!, to: :subject

  it "should find the incoming email record and pass it to covered.process_incoming_email" do
    incoming_email = double(:incoming_email)
    expect_any_instance_of(Covered::IncomingEmails).to receive(:find_by_id!).with(42).and_return(incoming_email)
    expect(incoming_email).to receive(:process!)
    perform!(42)
  end

end
