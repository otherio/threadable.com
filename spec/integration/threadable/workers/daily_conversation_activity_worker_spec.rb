require 'spec_helper'

describe DailyConversationActivityWorker, :type => :request do
  let(:last_time) { Time.now.utc - 1.day }
  let(:time) { Time.now.utc }
  let(:raceteam) { threadable.organizations.find_by_slug('raceteam') }
  let(:sfhealth) { threadable.organizations.find_by_slug('sfhealth') }

  subject{ described_class.new }

  before do
    Time.zone = 'US/Pacific'
    subject.instance_variable_set(:@threadable, threadable)
  end

  delegate :perform!, to: :subject

  describe 'process!' do
    before do
      expect_any_instance_of(Threadable::Organization).to receive(:find_closeio_lead).at_least(:once).and_return(lead)
      expect(Closeio::Lead).to receive(:update).with('lead_id', 'custom.recent_activity' => 'yes')
    end

    let(:lead) { double(:lead, id: 'lead_id')}

    it 'tells close.io about active organizations, updates daily_last_message_at' do
      perform! last_time, time
      drain_background_jobs!
      binding.pry
      sfhealth.reload
      expect(sfhealth.daily_last_message_at).to eq sfhealth.last_message_at
    end

    context 'when the running about a month after the last activity' do
      let(:last_time) { Time.zone.local(2014, 2, 3) - 1.day }
      let(:time) { Time.zone.local(2014, 2, 3) }

    end

    it 'tells close.io about orgs that have become inactive' do
      pending
    end

  end

end
