# Encoding: UTF-8
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
      perform! :welcome, organization.id
      drain_background_jobs!
      expect(sent_emails.length).to eq 6
      expect(sent_emails.first.subject).to eq '[RaceTeam] Welcome to Threadable!'
      expect(sent_emails.first.html_part.to_s).to include organization.name
    end

    it 'creates a child message when a parent slug is specified' do
      perform! :tips_buttons, organization.id
      drain_background_jobs!
      sent_emails.clear

      total_conversations = organization.conversations.all.length
      perform! :tips_groups, organization.id
      drain_background_jobs!
      expect(organization.conversations.all.length).to eq total_conversations
      expect(sent_emails.length).to eq 6
      expect(sent_emails.first.subject).to eq 'Re: [RaceTeam] Threadable Tips'
    end
  end

end
