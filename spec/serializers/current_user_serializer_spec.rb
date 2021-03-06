require 'spec_helper'

describe CurrentUserSerializer do

  let(:alice) { threadable.users.find_by_email_address!('alice@ucsd.example.com') }
  let(:bob) { threadable.users.find_by_email_address!('bob@ucsd.example.com') }
  let(:marcus){ threadable.users.find_by_email_address!('marcus@sfhealth.example.com') }

  let(:expected_key){ :user }
  let(:payload){ current_user }

  context 'when signed in as alice' do
    before do
      threadable.current_user = alice
      alice.external_authorizations.add_or_update!(provider: 'trello', token: 'foo', secret: 'bar', name: 'Alice', email_address: 'foo@bar.com')
    end
    it do
      is_expected.to eq(
        id:                      'current',
        user_id:                 alice.user_id,
        param:                   alice.to_param,
        name:                    alice.name,
        email_address:           alice.email_address.to_s,
        slug:                    alice.slug,
        avatar_url:              alice.avatar_url,
        external_authorizations: serialize_model(:external_authorizations, alice.external_authorizations.all).values.first,
        current_organization_id: alice.current_organization_id,
        organizations:           serialize_model(:light_organizations, alice.organizations.all).values.first,
        dismissed_welcome_modal: true,
      )
    end
  end

  context 'when signed in as bob, who has been removed forcefully from the org' do
    before do
      threadable.current_user = alice
      alice.organizations.all.first.members.find_by_email_address('bob@ucsd.example.com').remove
      threadable.current_user = bob
    end
    it do
      is_expected.to eq(
        id:                      'current',
        user_id:                 bob.user_id,
        param:                   bob.to_param,
        name:                    bob.name,
        email_address:           bob.email_address.to_s,
        slug:                    bob.slug,
        avatar_url:              bob.avatar_url,
        external_authorizations: [],
        current_organization_id: bob.current_organization_id,
        organizations:           [],
        dismissed_welcome_modal: true,
      )
    end
  end

  context 'when signed in as marcus' do
    before { threadable.current_user = marcus }
    it do
      is_expected.to eq(
        id:                      'current',
        user_id:                 marcus.user_id,
        param:                   marcus.to_param,
        name:                    marcus.name,
        email_address:           marcus.email_address.to_s,
        slug:                    marcus.slug,
        avatar_url:              marcus.avatar_url,
        external_authorizations: [],
        current_organization_id: marcus.current_organization_id,
        organizations:           serialize_model(:light_organizations, marcus.organizations.all).values.first,
        dismissed_welcome_modal: true,
      )
    end
  end
end
