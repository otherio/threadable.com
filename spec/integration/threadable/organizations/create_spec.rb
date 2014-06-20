require 'spec_helper'

describe Threadable::Organizations::Create do
  describe '#call' do
    let :params do
      {
        name: "Not your mom's company",
        slug: 'notyourmom',
        subject_tag: 'no',
        email_address_username: 'notyourmom',
      }
    end

    let(:organization) { threadable.organizations.find_by_slug('notyourmom') }

    before do
      expect(threadable.organizations.create(params)).to be_a Threadable::Organization
    end

    it 'creates the org' do
      expect(organization.name).to eq "Not your mom's company"
      expect(organization.email_address_username).to eq 'notyourmom'
      expect(organization.subject_tag).to eq 'no'
    end

    it 'populates the org with starter groups and enqueues the messages to be sent' do
      expect(organization.groups.all.map(&:slug)).to match_array ['social', 'notyourmom']
      drain_background_jobs!  # drains all scheduled jobs
      expect(organization.messages.all.length).to eq 4
    end

    it 'sets one of the starter groups to primary' do
      group = organization.groups.find_by_slug('notyourmom')
      expect(group.primary?).to be_true
      expect(group.auto_join?).to be_true
    end
  end
end
