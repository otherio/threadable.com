require 'spec_helper'

describe Threadable::User::ExternalAuthorizations do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:user) { organization.members.find_by_email_address('alice@ucsd.example.com') }

  describe '#add_or_update' do
    it 'adds' do
      user.external_authorizations.add_or_update(provider: 'twitterfax', token: 'foo', secret: 'bar')
      expect(user.external_authorizations.all.length).to eq 1
    end

    it 'updates' do
      user.external_authorizations.add_or_update(provider: 'twitterfax', token: 'foo', secret: 'bar')
      user.external_authorizations.add_or_update(provider: 'twitterfax', token: 'baz', secret: 'bar2')
      authorizations = user.external_authorizations.all
      expect(authorizations.length).to eq 1
      expect(authorizations.first.token).to eq 'baz'
    end
  end
end
