require 'spec_helper'

describe CurrentUserSerializer do

  let(:alice) { covered.users.find_by_email_address!('alice@ucsd.example.com') }
  let(:marcus){ covered.users.find_by_email_address!('marcus@sfhealth.example.com') }

  let(:expected_key){ :user }
  let(:payload){ current_user }

  context 'when not signed in' do
    before { covered.current_user = nil }
    it do
      should eq(
        id:            'current',
        user_id:       nil,
        param:         nil,
        name:          nil,
        email_address: nil,
        slug:          nil,
        avatar_url:    nil,
        organizations: [],
      )
    end
  end
  context 'when signed in as alice' do
    before { covered.current_user = alice }
    it do
      should eq(
        id:            'current',
        user_id:       alice.user_id,
        param:         alice.to_param,
        name:          alice.name,
        email_address: alice.email_address.to_s,
        slug:          alice.slug,
        avatar_url:    alice.avatar_url,
        organizations: serialize(:organizations, alice.organizations.all).values.first,
      )
    end
  end

  context 'when signed in as marcus' do
    before { covered.current_user = marcus }
    it do
      should eq(
        id:            'current',
        user_id:       marcus.user_id,
        param:         marcus.to_param,
        name:          marcus.name,
        email_address: marcus.email_address.to_s,
        slug:          marcus.slug,
        avatar_url:    marcus.avatar_url,
        organizations: serialize(:organizations, marcus.organizations.all).values.first,
      )
    end
  end


end
