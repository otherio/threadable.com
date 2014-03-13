require 'spec_helper'

describe ProcessIncomingIntegrationHookWorker do

  let(:incoming_integration_hook){ double(:incoming_integration_hook, provider: 'trello', external_message_id: 'EXTERNAL_MESSAGE_ID') }

  subject{ described_class.new }

  before do
    Timecop.freeze
    subject.instance_variable_set(:@threadable, threadable)
    expect_any_instance_of(Threadable::IncomingIntegrationHooks).to receive(:find_by_id!).with(42).and_return(incoming_integration_hook)
  end
  delegate :perform!, to: :subject


  context "when another message with the same message_id is not being processed" do
    before do
      expect(Threadable.redis).to receive(:setnx).with('ProcessIncomingIntegrationHookWorker:trello-EXTERNAL_MESSAGE_ID', Time.now.to_i).and_return(true)
    end

    it "should find the incoming integration_hook record and pass it to threadable.process_incoming_integration_hook" do
      expect(Threadable.redis).to receive(:expire).with('ProcessIncomingIntegrationHookWorker:trello-EXTERNAL_MESSAGE_ID', 30).and_return(true)
      expect(incoming_integration_hook).to receive(:process!)
      expect(Threadable.redis).to receive(:del).with('ProcessIncomingIntegrationHookWorker:trello-EXTERNAL_MESSAGE_ID')
      perform!(42)
      expect(described_class.jobs).to be_empty
    end
  end
  context "when another message with the same message_id is being processed" do
    before do
      expect(Threadable.redis).to receive(:setnx).with('ProcessIncomingIntegrationHookWorker:trello-EXTERNAL_MESSAGE_ID', Time.now.to_i).and_return(false)
    end
    it "should reschedule itself for 5 seconds from now" do
      expect(Threadable.redis).to_not receive(:expire)
      expect(incoming_integration_hook).to_not receive(:process!)
      expect(Threadable.redis).to_not receive(:del)
      perform!(42)
      expect(described_class.jobs.first['at']).to eq 5.seconds.from_now.to_f
    end
  end

end
