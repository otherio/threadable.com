require 'spec_helper'

describe Threadable::User do
  let(:user){ threadable.users.find_by_email_address('bethany@ucsd.example.com') }
  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:electronics) { organization.groups.find_by_email_address_tag('electronics') }
  let(:fundraising) { organization.groups.find_by_email_address_tag('fundraising') }
  subject{ user }



  describe "#receives_email_for_groups?" do

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

  describe "#limited_group_ids" do
    context "when the current user is subscribed to one or more groups with summary" do
      before do
        user.groups.all.each do |group|
          membership = group.members.find_by_user_id!(user.id)
          membership.gets_in_summary!
        end
      end

      it 'returns the ids of those groups' do
        expect(user.limited_group_ids).to include( electronics.id )
      end
    end

  end
end
