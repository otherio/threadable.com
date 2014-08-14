require 'spec_helper'

describe GroupMembersSerializer do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:group)       { organization.groups.find_by_slug! 'fundraising' }
  let(:alice)       { group.members.find_by_user_id! organization.members.find_by_email_address!('alice@ucsd.example.com').user_id }
  let(:bob)         { group.members.find_by_user_id! organization.members.find_by_email_address!('bob@ucsd.example.com').user_id }

  context 'when given a single record' do
    let(:payload){ alice }
    let(:expected_key){ :group_member }
    it do
      should eq(
        id:              alice.id,
        user_id:         alice.user_id,
        param:           "alice-neilson",
        name:            "Alice Neilson",
        email_address:   "alice@ucsd.example.com",
        slug:            "alice-neilson",
        avatar_url:      "/fixture_images/alice.jpg",
        delivery_method: "gets_each_message",
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [alice,bob] }
    let(:expected_key){ :group_members }
    it do
      should eq [
        {
          id:              alice.id,
          user_id:         alice.user_id,
          param:           "alice-neilson",
          name:            "Alice Neilson",
          email_address:   "alice@ucsd.example.com",
          slug:            "alice-neilson",
          avatar_url:      "/fixture_images/alice.jpg",
          delivery_method: "gets_each_message",
        },{
          id:              bob.id,
          user_id:         bob.user_id,
          param:           "bob-cauchois",
          name:            "Bob Cauchois",
          email_address:   "bob@ucsd.example.com",
          slug:            "bob-cauchois",
          avatar_url:      "/fixture_images/bob.jpg",
          delivery_method: "gets_in_summary",
        }
      ]
    end
  end

end
