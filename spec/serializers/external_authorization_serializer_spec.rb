require 'spec_helper'

describe ExternalAuthorizationsSerializer do

  let(:raceteam) { threadable.organizations.find_by_slug!('raceteam') }
  let(:alice) { raceteam.members.find_by_email_address('alice@ucsd.example.com')}

  context 'when given a single record' do
    before do
      alice.external_authorizations.add_or_update!(
        provider: 'trello',
        token: 'foo',
        secret: 'bar',
        name: 'Alice Neilson',
        email_address: 'alice@foo.com',
        nickname: 'alice',
        url: 'http://foo.com/',
        unique_id: '12345'
      )
    end
    let(:payload){ alice.external_authorizations.all.first }
    let(:expected_key){ :external_authorization }

    it do
      should eq(
        provider: 'trello',
        name: 'Alice Neilson',
        email_address: 'alice@foo.com',
        nickname: 'alice',
        url: 'http://foo.com/',
        token: 'foo',
        application_key: ENV['THREADABLE_TRELLO_API_KEY'],
        unique_id: '12345',
      )
    end
  end
end
