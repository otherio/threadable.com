require 'spec_helper'

describe Threadable::User, :type => :request do
  let(:user){ threadable.users.find_by_email_address('bethany@ucsd.example.com') }
  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:electronics) { organization.groups.find_by_email_address_tag('electronics') }
  let(:fundraising) { organization.groups.find_by_email_address_tag('fundraising') }
  subject{ user }



  describe "#receives_email_for_groups?" do
    context "when the current user is a group member of one or more supplied groups" do
      it 'returns true' do
        expect(user.receives_email_for_groups? [electronics, fundraising] ).to be_truthy
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
        expect(user.receives_email_for_groups? [electronics, fundraising] ).to be_falsey
      end
    end
  end

  describe "#receives_first_message_for_groups?" do
    context "when the current user has a first-message subscription to one or more supplied groups" do
      before do
        user.groups.all.each do |group|
          membership = group.members.find_by_user_id!(user.id)
          membership.gets_first_message!
        end
      end

      it 'returns true' do
        expect(user.receives_first_message_for_groups? [electronics, fundraising] ).to be_truthy
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
        expect(user.receives_email_for_groups? [electronics, fundraising] ).to be_falsey
      end
    end
  end

  describe "#current_organization" do
    before do
      user.update(current_organization_id: organization.id)
    end

    it 'returns a Threadable::Organization' do
      expect(user.current_organization).to be_a(Threadable::Organization)
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

    context "when the current user is subscribed to one or more groups with first-message" do
      before do
        user.groups.all.each do |group|
          membership = group.members.find_by_user_id!(user.id)
          membership.gets_first_message!
        end
      end

      it 'returns the ids of those groups' do
        expect(user.limited_group_ids).to include( electronics.id )
      end
    end
  end

  describe '#organization_owner' do
    let(:alice) { threadable.users.find_by_email_address('alice@ucsd.example.com') }
    let(:bob)   { threadable.users.find_by_email_address('bob@ucsd.example.com') }

    it 'reports whether the user owns at least one org' do
      expect(alice.organization_owner).to be_truthy
      expect(bob.organization_owner).to be_falsey
    end
  end
end
