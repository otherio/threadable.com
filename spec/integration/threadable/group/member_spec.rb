require 'spec_helper'

describe Threadable::Group::Member, :type => :request do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:group){ organization.groups.find_by_email_address_tag!('electronics') }
  let(:member){ group.members.all.first }
  subject{ member }

  describe '#user' do
    it 'returns the member of the group as Threadable::User instances' do
      expect( member ).to be_a Threadable::User
    end
  end

  describe '#update' do
    before do
      sign_in_as 'bethany@ucsd.example.com'
    end

    context 'when the current user has permission to change group settings' do
      it 'updates the group' do
        member.update(delivery_method: 'gets_first_message')
        expect(member.delivery_method).to eq 'gets_first_message'
      end
    end

    context 'when the current user does not have permission to change group member settings' do
      before do
        organization.organization_record.update_attribute(:group_membership_permission, 1)
      end

      it 'raises an error' do
        expect { member.update(delivery_method: 'gets_first_message') }.to raise_error Threadable::AuthorizationError, 'You do not have permission to change delivery settings for this group'
      end
    end
  end
end

