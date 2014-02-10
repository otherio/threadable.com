require 'spec_helper'

describe GroupMembersSerializer do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:group){ organization.groups.find_by_slug! 'fundraising' }
  let(:alice) { group.members.find_by_email_address!('alice@ucsd.example.com') }
  let(:bob){ group.members.find_by_email_address!('bob@ucsd.example.com') }

  context 'when given a single record' do
    let(:payload){ alice }
    let(:expected_key){ :group_member }
    it do
      should eq(
        id:            alice.id,
        user_id:       alice.user_id,
        param:         "alice-neilson",
        name:          "Alice Neilson",
        email_address: "alice@ucsd.example.com",
        slug:          "alice-neilson",
        avatar_url:    "/fixture_images/alice.jpg",
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [alice,marcus] }
    let(:expected_key){ :group_members }
    it do
      should eq [
        {
          id:            alice.id,
          user_id:       alice.user_id,
          param:         "alice-neilson",
          name:          "Alice Neilson",
          email_address: "alice@ucsd.example.com",
          slug:          "alice-neilson",
          avatar_url:    "/fixture_images/alice.jpg",
        },{
          id:            bob.id,
          user_id:       bob.user_id,
          param:         "bob-cauchois",
          name:          "Bob Cauchois",
          email_address: "bob@ucsd.example.com",
          slug:          "bob-cauchois",
          avatar_url:    "/fixture_images/bob.jpg",
        }
      ]
    end
  end

end
