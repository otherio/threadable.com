require 'spec_helper'

describe Api::MembersSerializer do

  let(:alice) { covered.users.find_by_email_address!('alice@ucsd.example.com') }
  let(:marcus){ covered.users.find_by_email_address!('marcus@sfhealth.example.com') }

  context 'when given a single record' do
    subject{ described_class[alice] }
    it do
      should eq(
        member: {
          id:            alice.id,
          param:         "alice-neilson",
          name:          "Alice Neilson",
          email_address: "alice@ucsd.example.com",
          slug:          "alice-neilson",
          avatar_url:    "/fixture_images/alice.jpg",
        }
      )
    end
  end

  context 'when given a collection of records' do
    subject{ described_class[[alice,marcus]] }
    it do
      should eq(
        members: [
          {
            id:            alice.id,
            param:         "alice-neilson",
            name:          "Alice Neilson",
            email_address: "alice@ucsd.example.com",
            slug:          "alice-neilson",
            avatar_url:    "/fixture_images/alice.jpg",
          },{
            id:            marcus.id,
            param:         "marcus-welby",
            name:          "Marcus Welby",
            email_address: "marcus@sfhealth.example.com",
            slug:          "marcus-welby",
            avatar_url:    "/fixture_images/marcus.jpg",
          }
        ]
      )
    end
  end

end
