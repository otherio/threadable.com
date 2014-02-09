require 'spec_helper'

describe ProcessIncomingEmailWorker do

  let(:incoming_email){ double(:incoming_email, message_id: '<9fe7229c2e5c88cbde6b5a6a4c99bc3fb7c2144e@example.com>') }

  subject{ described_class.new }

  before do
    Timecop.freeze
    subject.instance_variable_set(:@threadable, threadable)
    expect_any_instance_of(Threadable::IncomingEmails).to receive(:find_by_id!).with(42).and_return(incoming_email)
  end
  delegate :perform!, to: :subject


  context "when another message with the same message_id is not being processed" do
    before do
      expect(Threadable.redis).to receive(:exists).with('ProcessIncomingEmailWorker:<9fe7229c2e5c88cbde6b5a6a4c99bc3fb7c2144e@example.com>').and_return(false)
    end

    it "should find the incoming email record and pass it to threadable.process_incoming_email" do
      expect(Threadable.redis).to receive(:set).with('ProcessIncomingEmailWorker:<9fe7229c2e5c88cbde6b5a6a4c99bc3fb7c2144e@example.com>', Time.now.to_i)
      expect(Threadable.redis).to receive(:expire).with('ProcessIncomingEmailWorker:<9fe7229c2e5c88cbde6b5a6a4c99bc3fb7c2144e@example.com>', 30)
      expect(incoming_email).to receive(:process!)
      expect(Threadable.redis).to receive(:del).with('ProcessIncomingEmailWorker:<9fe7229c2e5c88cbde6b5a6a4c99bc3fb7c2144e@example.com>')
      perform!(42)
      expect(described_class.jobs).to be_empty
    end
  end
  context "when another message with the same message_id is being processed" do
    before do
      expect(Threadable.redis).to receive(:exists).with('ProcessIncomingEmailWorker:<9fe7229c2e5c88cbde6b5a6a4c99bc3fb7c2144e@example.com>').and_return(true)
    end
    it "should reschedule itself for 5 seconds from now" do
      expect(Threadable.redis).to_not receive(:set)
      expect(Threadable.redis).to_not receive(:expire)
      expect(incoming_email).to_not receive(:process!)
      expect(Threadable.redis).to_not receive(:del)
      perform!(42)
      expect(described_class.jobs.first['at']).to eq 5.seconds.from_now.to_f
    end
  end

end
