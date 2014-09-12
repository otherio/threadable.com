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

    context 'when signed in' do
      before do
        sign_in_as 'alice@ucsd.example.com'
      end

      context 'when the organization is free' do
        before do
          organization.organization_record.update_attribute(:plan, :free)
        end
        it 'does not allow creating a private group' do
          expect{organization.groups.create(name: 'foo', private: true)}.to raise_error Threadable::AuthorizationError, 'You do not have permission to make private groups for this organization'
        end
      end

      context 'when the organization is paid' do
        before do
          organization.organization_record.update_attribute(:plan, :paid)
        end

        it 'allows creating a private group' do
          group = organization.groups.create(name: 'foo', private: true)
          expect(group.private?).to be_truthy
        end
      end
    end

  end
end
