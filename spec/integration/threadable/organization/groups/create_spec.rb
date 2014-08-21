require 'spec_helper'

describe Threadable::Organization::Groups::Create, :type => :request do
  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }

  describe '#call' do
    context 'with the auto_join flag set to true' do
      before do
        sign_in_as 'alice@ucsd.example.com'
      end

      it 'adds all the current members to the group' do
        group = organization.groups.create(name: 'foo', auto_join: true)
        expect(group.members.count).to eq organization.members.count
        drain_background_jobs!
        expect(sent_emails.length).to eq 8
      end
    end

    context 'with the auto_join flag set to false' do
      it 'does not add any members to the group' do
        group = organization.groups.create(name: 'foo', auto_join: false)
        expect(group.members.count).to eq 0
      end
    end

    context 'with the auto_join flag unset' do
      it 'does not add any members to the group' do
        group = organization.groups.create(name: 'foo')
        expect(group.members.count).to eq 0
      end
    end
  end
end
