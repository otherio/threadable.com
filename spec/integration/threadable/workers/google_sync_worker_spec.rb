# Encoding: UTF-8
require 'spec_helper'

describe GoogleSyncWorker do
  subject{ described_class.new }

  before do
    subject.instance_variable_set(:@threadable, threadable)
  end

  delegate :perform!, to: :subject

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:group) { organization.groups.find_by_slug('electronics') }

  describe 'perform!' do
    it 'calls google sync' do
      expect(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).
        with(threadable, group)

      perform! organization.id, group.id
    end

    it 'does not run duplicate jobs' do
      expect(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).
        with(anything, group).
        once

      described_class.perform_async(threadable.env, organization.id, group.id)
      described_class.perform_async(threadable.env, organization.id, group.id)
      drain_background_jobs!
    end
  end
end
