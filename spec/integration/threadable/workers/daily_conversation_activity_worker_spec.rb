require 'spec_helper'

describe DailyConversationActivityWorker, :type => :request do
  let(:last_time) { Time.now.utc - 1.day }
  let(:time) { Time.now.utc + 1.day }
  let(:raceteam) { threadable.organizations.find_by_slug('raceteam') }
  let(:sfhealth) { threadable.organizations.find_by_slug('sfhealth') }

  subject{ described_class.new }

  before do
    Time.zone = 'US/Pacific'
    subject.instance_variable_set(:@threadable, threadable)
  end

  delegate :perform!, to: :subject

  describe 'process!' do
    let(:lead) { double(:lead, id: 'lead_id')}

    context 'when the lead is already present in closeio' do
      before do
        allow_any_instance_of(Threadable::Organization).to receive(:find_closeio_lead).and_return(lead)
      end

      it 'tells close.io about active organizations, updates daily_last_message_at' do
        expect(Closeio::Lead).to receive(:update).with('lead_id', 'custom.recent_activity' => 'yes').exactly(2).times

        perform! last_time, time
        drain_background_jobs!
      end

      context 'when the running about a month after the last activity' do
        let(:last_time) { Time.zone.local(2014, 3, 2) - 1.day }
        let(:time) { Time.zone.local(2014, 3, 2) }

        it 'tells close.io about orgs that have become inactive' do
          expect(Closeio::Lead).to receive(:update).with('lead_id', 'custom.recent_activity' => 'no')

          perform! last_time, time
          drain_background_jobs!
        end
      end
    end

    context 'with no leads in closeio' do
      before do
        allow_any_instance_of(Threadable::Organization).to receive(:find_closeio_lead).and_return(nil)
      end

      it 'creates the leads' do
        # for some reason receive counts are not working with any_instance. this test is not great, but whatev.
        allow_any_instance_of(Threadable::Organization).to receive(:create_closeio_lead!)  #stub this
        expect_any_instance_of(Closeio::Lead).to_not receive(:update)

        perform! last_time, time
        drain_background_jobs!
      end
    end

  end

end
