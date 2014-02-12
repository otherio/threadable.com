require 'spec_helper'

describe SendSummaryEmailWorker do
  let(:time) { Time.now.in_time_zone('US/Pacific') }
  subject{ described_class.new }

  before do
    subject.instance_variable_set(:@threadable, threadable)
  end

  delegate :perform!, to: :subject

  describe 'process!' do
    it 'sends emails to all members in all orgs with summaries' do
      perform! time
      drain_background_jobs!
      expect(sent_emails.length).to eq 2
    end
  end

end
