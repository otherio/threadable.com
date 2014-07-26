require 'spec_helper'

describe EmptyTrashWorker do
  let(:last_time) { Time.zone.local(2014, 2, 3) - 1.day }
  let(:time) { Time.zone.local(2014, 2, 3) }
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:conversation) { organization.conversations.find_by_slug('layup-body-carbon') }

  subject{ described_class.new }

  before do
    Time.zone = 'US/Pacific'
    subject.instance_variable_set(:@threadable, threadable)
  end

  delegate :perform!, to: :subject

  describe 'process!' do
    before do
      conversation.conversation_record.update(trashed_at: Time.zone.local(2014, 2, 3) - 31.days)
    end

    it 'deletes conversations that were moved into the trash more than 30 days ago' do
      perform! last_time, time
      drain_background_jobs!

      expect(organization.conversations.find_by_slug('layup-body-carbon')).to be_nil
    end
  end

end
