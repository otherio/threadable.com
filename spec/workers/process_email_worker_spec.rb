require 'spec_helper'

describe ProcessEmailWorker do

  it "should call Covered.process_incoming_email" do
    fake_incoming_email = double(:fake_incoming_email)
    IncomingEmail.should_receive(:find).with(12).and_return(fake_incoming_email)
    Covered.should_receive(:process_incoming_email).with(:email => fake_incoming_email)

    ProcessEmailWorker.perform('incoming_email_id' => 12)
  end

end
