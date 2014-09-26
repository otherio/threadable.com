require 'spec_helper'

describe Threadable::Organization::Member::Update, :type => :request do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:member) { organization.members.find_by_email_address('tom@ucsd.example.com') }
  let(:self_member) { organization.members.find_by_email_address('bethany@ucsd.example.com') }

  before do
    sign_in_as 'bethany@ucsd.example.com'
  end

  context 'when allowed to change member subscription settings' do
    it 'sets the subscribed flag' do
      described_class.call(member, subscribed: false)
      expect(member.subscribed?).to be_falsy
    end
  end

  context 'when not allowed to change member subscription settings' do
    before do
      organization.organization_record.update_attribute(:organization_membership_permission, 1)
    end

    it 'raises an exception' do
      expect{described_class.call(member, subscribed: false)}.to raise_error Threadable::AuthorizationError, 'You cannot change subscription settings for this member'
    end

    it 'sets the subscribed flag when the member is the current user' do
      described_class.call(self_member, subscribed: false)
      expect(self_member.subscribed?).to be_falsy
    end
  end


end
