require 'spec_helper'

require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'

describe Threadable::Integrations::Google::Client do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:alice) { organization.members.find_by_email_address('alice@ucsd.example.com')}

  let(:described_module) do
    Class.new{
    }.send(:include, described_class).new
  end

  let!(:external_authorization) do
    alice.external_authorizations.add_or_update!(
      provider: 'google_oauth2',
      token: 'foo',
      refresh_token: 'moar foo',
      name: 'Alice Neilson',
      email_address: 'alice@foo.com',
      domain: 'foo.com',
    )
  end

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  describe '.client_for' do
    context 'with proper google credentials' do
      before do
        ENV['GOOGLE_CLIENT_ID'] = 'CLIENT ID'
        ENV['GOOGLE_CLIENT_SECRET'] = 'CLIENT SECRET'
      end

      it 'returns a valid and correct Google::APIClient object' do
        client = described_module.client_for(alice)
        expect(client).to be_a Google::APIClient
        expect(client.authorization.access_token).to eq 'foo'
        expect(client.authorization.refresh_token).to eq 'moar foo'
        expect(client.authorization.client_id).to eq 'CLIENT ID'
        expect(client.authorization.client_secret).to eq 'CLIENT SECRET'
      end
    end

    context 'with no google credentials' do
      let(:external_authorization) { nil }
      it 'raises an exception' do
        expect { described_module.client_for(alice) }.to raise_error Threadable::ExternalServiceError, 'No connected google account'
      end
    end
  end

  describe '.directory_api' do
    let(:api_description) { double(:api_description) }

    it 'returns a Google::APIClient object' do
      client = described_module.client_for(alice)
      expect(client).to receive(:discovered_api).with('admin', 'directory_v1').and_return(api_description)
      expect(described_module.directory_api).to eq api_description
    end

    it 'fails when no client has been initialized' do
      expect{ described_module.directory_api }.to raise_error Threadable::ExternalServiceError, 'No client present'
    end
  end

  describe '.groups_settings_api' do
    let(:api_description) { double(:api_description) }

    it 'returns a Google::APIClient object' do
      client = described_module.client_for(alice)
      expect(client).to receive(:discovered_api).with('groupssettings').and_return(api_description)
      expect(described_module.groups_settings_api).to eq api_description
    end

    it 'fails when no client has been initialized' do
      expect{ described_module.groups_settings_api }.to raise_error Threadable::ExternalServiceError, 'No client present'
    end
  end

  describe '.extract_error_message' do
    let(:insert_response) { double(:insert_response, status: 500, body: insert_response_body) }
    let(:insert_response_body) { "{\n \"error\": {\n  \"errors\": [\n   {\n    \"domain\": \"global\",\n    \"reason\": \"notFound\",\n    \"message\": \"Resource Not Found: raindrift+hey@gmail.com\"\n   }\n  ],\n  \"code\": 404,\n  \"message\": \"Resource Not Found: raindrift+hey@gmail.com\"\n }\n}\n" }

    it 'fetches the error message' do
      expect(described_module.extract_error_message(insert_response)).to eq "Resource Not Found: raindrift+hey@gmail.com"
    end

    context 'with no valid error message' do
      let(:insert_response_body) { nil }

      it 'returns (no error message found)' do
        expect(described_module.extract_error_message(insert_response)).to eq '(no error message found)'
      end
    end
  end
end
