require 'spec_helper'

describe OrganizationMembersSerializer do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:alice) { organization.members.find_by_email_address!('alice@ucsd.example.com') }
  let(:bob){ organization.members.find_by_email_address!('bob@ucsd.example.com') }

  context 'when given a single record' do
    let(:payload){ alice }
    let(:expected_key){ :organization_member }
    it do
      should eq(
        id:            alice.id,
        user_id:       alice.user_id,
        param:         "alice-neilson",
        name:          "Alice Neilson",
        email_address: "alice@ucsd.example.com",
        slug:          "alice-neilson",
        avatar_url:    "/fixture_images/alice.jpg",
        subscribed:    true,
        role:          :owner,
        ungrouped_mail_delivery: :each_message,
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [alice,bob] }
    let(:expected_key){ :organization_members }
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
          subscribed:    true,
          role:          :owner,
          ungrouped_mail_delivery: :each_message,
        },{
          id:            bob.id,
          user_id:       bob.user_id,
          param:         "bob-cauchois",
          name:          "Bob Cauchois",
          email_address: "bob@ucsd.example.com",
          slug:          "bob-cauchois",
          avatar_url:    "/fixture_images/bob.jpg",
          subscribed:    true,
          role:          :member,
          ungrouped_mail_delivery: :each_message,
        }
      ]
    end
  end

end
