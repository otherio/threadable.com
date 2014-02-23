require 'spec_helper'

describe CurrentUserSerializer do

  let(:alice) { threadable.users.find_by_email_address!('alice@ucsd.example.com') }
  let(:marcus){ threadable.users.find_by_email_address!('marcus@sfhealth.example.com') }

  let(:expected_key){ :user }
  let(:payload){ current_user }

  context 'when signed in as alice' do
    before { threadable.current_user = alice }
    it do
      should eq(
        id:                      'current',
        user_id:                 alice.user_id,
        param:                   alice.to_param,
        name:                    alice.name,
        email_address:           alice.email_address.to_s,
        slug:                    alice.slug,
        avatar_url:              alice.avatar_url,
        current_organization_id: alice.current_organization_id,
        organizations:           serialize(:organizations, alice.organizations.all).values.first,
      )
    end
  end

  context 'when signed in as marcus' do
    before { threadable.current_user = marcus }
    it do
      should eq(
        id:                      'current',
        user_id:                 marcus.user_id,
        param:                   marcus.to_param,
        name:                    marcus.name,
        email_address:           marcus.email_address.to_s,
        slug:                    marcus.slug,
        avatar_url:              marcus.avatar_url,
        current_organization_id: marcus.current_organization_id,
        organizations:           serialize(:organizations, marcus.organizations.all).values.first,
      )
    end
  end


end
