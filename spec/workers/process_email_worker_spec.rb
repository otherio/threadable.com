require 'spec_helper'

describe ProcessEmailWorker do

  it "should call EmailProcessor.process_email(@email)" do
    fake_incoming_email = double(:fake_incoming_email)
    IncomingEmail.should_receive(:find).with(12).and_return(fake_incoming_email)
    EmailProcessor.should_receive(:call).with(fake_incoming_email)

    ProcessEmailWorker.perform('incoming_email_id' => 12)
  end

end
