require 'spec_helper'

describe SendStarterContentWorker do
  subject{ described_class.new }

  before do
    subject.instance_variable_set(:@threadable, threadable)
  end

  delegate :perform!, to: :subject

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }

  describe 'process!' do
    it 'creates the specified message in the specified organization' do
      perform! :day_one, organization.id
      drain_background_jobs!
      expect(sent_emails.length).to eq 8 #or whatever this is
      expect(sent_emails.map(&:subject)).to match_array [
        "Day one subject line"
      ]
    end

    it 'creates a child message when a parent slug is specified' do
      total_conversations = organization.conversations.all.length
      perform! :day_two, organization.id
      drain_background_jobs!
      expect(organization.conversations.all.length).to eq total_conversations
      expect(sent_emails.length).to eq 8 #or whatever this is
      expect(sent_emails.map(&:subject)).to match_array [
        "day two subject line"
      ]
    end
  end

end
