require 'spec_helper'

describe Threadable::User::ExternalAuthorization do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:user) { organization.members.find_by_email_address('alice@ucsd.example.com') }
  let(:external_authorization_record) { user.user_record.external_authorizations.create(provider: provider, token: 'foo', secret: 'bar') }
  let(:external_authorization) { described_class.new(user, external_authorization_record) }
  let(:provider) {'twitterfax'}

  it 'makes a record' do
    expect(external_authorization).to be_a Threadable::User::ExternalAuthorization
    expect(external_authorization.provider).to eq 'twitterfax'
    expect(external_authorization.token).to eq 'foo'
    expect(external_authorization.secret).to eq 'bar'
  end

  describe '#pretty_provider' do
    let(:provider) {'google_oauth2'}

    it "translates the provider name to the pretty version" do
      expect(external_authorization.pretty_provider).to eq "Google"
    end
  end
end
