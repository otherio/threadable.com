require 'spec_helper'

describe Threadable::User do
  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:user){ threadable.users.find_by_email_address('bethany@ucsd.example.com') }
  subject{ user }

  describe "#receives_email_for_groups?" do
    let(:electronics) { organization.groups.find_by_email_address_tag('electronics') }
    let(:fundraising) { organization.groups.find_by_email_address_tag('fundraising') }

    context "when the current user is a group member of one or more supplied groups" do
      it 'returns true' do
        expect(user.receives_email_for_groups? [electronics, fundraising] ).to be_true
      end
    end

    context "when the current user is a group member subscribed to only summaries" do
      before do
        user.groups.all.each do |group|
          membership = group.members.find_by_user_id!(user.id)
          membership.gets_in_summary!
        end
      end

      it 'returns false' do
        expect(user.receives_email_for_groups? [electronics, fundraising] ).to be_false
      end
    end
  end
end
