require 'spec_helper'

describe SendSummaryEmailWorker do
  let(:last_time) { Time.zone.local(2014, 2, 3) - 1.day }
  let(:time) { Time.zone.local(2014, 2, 3) }
  subject{ described_class.new }

  before do
    Time.zone = 'US/Pacific'
    subject.instance_variable_set(:@threadable, threadable)
  end

  delegate :perform!, to: :subject

  describe 'process!' do
    it 'sends emails to all members in all orgs with summaries' do
      perform! last_time, time
      drain_background_jobs!
      expect(sent_emails.length).to eq 2
      expect(sent_emails.map(&:subject)).to match_array [
        "[RaceTeam] Summary for Sun, Feb 2: 4 new messages in 3 conversations",
        "[RaceTeam] Summary for Sun, Feb 2: 12 new messages in 5 conversations"
      ]
    end
  end

end
