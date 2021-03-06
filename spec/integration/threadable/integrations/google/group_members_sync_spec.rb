require 'spec_helper'

describe Threadable::Integrations::Google::GroupMembersSync, :type => :request do

  delegate :call, to: described_class

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:group) { organization.groups.find_by_slug('electronics') }
  let(:alice) { organization.members.find_by_email_address('alice@ucsd.example.com')}
  let(:bob) { organization.members.find_by_email_address('bob@ucsd.example.com')}

  let(:google_client) { double(:google_client, authorization: double(:authorization), discovered_api: google_directory_api) }
  let(:google_directory_api) { double(:google_directory_api, members: directory_api_members)}
  let(:directory_api_members) do
    double(
      :directory_api_members,
      list: 'LIST API DESCRIPTION',
      insert: 'INSERT API DESCRIPTION',
      delete: 'DELETE API DESCRIPTION',
    )
  end

  let(:list_response) { double(:list_response, status: 200, body: response_body) }
  let(:response_body) do
    {
      "kind"=>"admin#directory#members",
      "members"=> google_group_members.nil? ? nil : google_group_members.map do |email|
        {
          "kind"=>"admin#directory#member",
          "email"=>email,
          "role"=>"MEMBER",
          "type"=>"USER"
        }
      end
    }.to_json
  end

  before do
    sign_in_as 'alice@ucsd.example.com'

    alice.external_authorizations.add_or_update!(
      provider: 'google_oauth2',
      token: 'foo',
      refresh_token: 'moar foo',
      name: 'Alice Neilson',
      email_address: 'alice@foo.com',
      domain: 'foo.com',
    )

    alice_as_user = Threadable::User.new(threadable, alice.user_record)
    expect_any_instance_of(described_class).to receive(:client_for).with(alice_as_user).and_return(google_client)
    allow_any_instance_of(described_class).to receive(:directory_api).and_return(google_directory_api)

    group.update(alias_email_address: '"Electronics for Jesus" <electronics@foo.com>')
    group.group_record.update_attributes(google_sync: true)
    organization.google_user = alice
    expect(google_client).to receive(:execute).with(api_method: 'LIST API DESCRIPTION', parameters: {'groupKey' => 'electronics@foo.com', 'maxResults' => 1000 }).and_return(list_response)
  end

  context 'when the google group and the threadable group have the same members' do
    let(:google_group_members) { [ 'tom@ucsd.example.com', 'bethany@ucsd.example.com' ] }

    it 'does nothing' do
      expect(google_client).to_not receive(:execute).with(api_method: 'INSERT API DESCRIPTION', parameters: anything, body_object: anything)
      call(threadable, group)
    end

    context 'when membership matches, but the google group membership uses a non-primary threadable email address' do
      let(:tom) { organization.members.find_by_email_address('tom@ucsd.example.com')}
      let(:google_group_members) { [ 'tomfoo@foo.com', 'bethany@ucsd.example.com' ] }

      before do
        tom.email_addresses.add('tomfoo@foo.com', primary: false)
      end

      it 'does nothing' do
        expect(google_client).to_not receive(:execute).with(api_method: 'INSERT API DESCRIPTION', parameters: anything, body_object: anything)
        call(threadable, group)
      end
    end
  end

  context 'when the threadable group has members that are not in the google group' do
    let(:tom) { organization.members.find_by_email_address('tom@ucsd.example.com')}
    let(:google_group_members) { nil }
    let(:insert_response) { double(:insert_response, status: 200) }

    before do
      tom.email_addresses.add('tomfoo@foo.com', primary: false)
    end

    it 'adds the members to the google group using their domain addresses' do
      expect(google_client).to receive(:execute).with(
        api_method: 'INSERT API DESCRIPTION',
        parameters: {'groupKey' => 'electronics@foo.com' },
        body_object: {
          'email' => 'bethany@ucsd.example.com'
        }
      ).and_return(insert_response)

      expect(google_client).to receive(:execute).with(
        api_method: 'INSERT API DESCRIPTION',
        parameters: {'groupKey' => 'electronics@foo.com' },
        body_object: {
          'email' => 'tomfoo@foo.com'
        }
      ).and_return(insert_response)

      call(threadable, group)
    end

    context 'when adding a member fails' do
      let(:insert_response) { double(:insert_response, status: 500, body: insert_response_body) }
      let(:insert_response_body) { "{\n \"error\": {\n  \"errors\": [\n   {\n    \"domain\": \"global\",\n    \"reason\": \"notFound\",\n    \"message\": \"Resource Not Found: raindrift+hey@gmail.com\"\n   }\n  ],\n  \"code\": 404,\n  \"message\": \"Resource Not Found: raindrift+hey@gmail.com\"\n }\n}\n" }

      before do
        expect(google_client).to receive(:execute).with(
          api_method: 'INSERT API DESCRIPTION',
          parameters: {'groupKey' => 'electronics@foo.com' },
          body_object: anything
        ).and_return(insert_response)
      end

      it 'raises an exception' do
        expect{ call(threadable, group) }.to raise_error Threadable::ExternalServiceError
      end

      context 'when the failure happens because the user is already a group member, but under a different email address' do
        let(:insert_response) { double(:insert_response, status: 409, body: nil) }

        it 'continues adding members' do
          expect(google_client).to receive(:execute).with(
            api_method: 'INSERT API DESCRIPTION',
            parameters: {'groupKey' => 'electronics@foo.com' },
            body_object: anything
          ).and_return(insert_response)

          call(threadable, group)
        end
      end
    end
  end

  context 'when the google group contains members who are not part of the threadable group' do
    let(:tom) { organization.members.find_by_email_address('tom@ucsd.example.com')}
    let(:google_group_members) { [ 'foo@bar.com', 'bob@ucsd.example.com', 'bethany@ucsd.example.com', 'tomfoo@foo.com' ] }
    let(:delete_response) { double(:delete_response, status: 200) }

    before do
      tom.email_addresses.add('tomfoo@foo.com', primary: false)
    end

    it 'removes the extra members from the google group' do
      expect(google_client).to receive(:execute).with(
        api_method: 'DELETE API DESCRIPTION',
        parameters: {
          'groupKey' => 'electronics@foo.com',
          'memberKey' => 'bob@ucsd.example.com'
        }
      ).and_return(delete_response)

      expect(google_client).to receive(:execute).with(
        api_method: 'DELETE API DESCRIPTION',
        parameters: {
          'groupKey' => 'electronics@foo.com',
          'memberKey' => 'foo@bar.com'
        }
      ).and_return(delete_response)

      call(threadable, group)
    end

    context 'when removing a member fails' do
      let(:delete_response) { double(:delete_response, status: 500, body: delete_response_body) }
      let(:delete_response_body) { "{\n \"error\": {\n  \"errors\": [\n   {\n    \"domain\": \"global\",\n    \"reason\": \"notFound\",\n    \"message\": \"Resource Not Found: raindrift+hey@gmail.com\"\n   }\n  ],\n  \"code\": 404,\n  \"message\": \"Resource Not Found: raindrift+hey@gmail.com\"\n }\n}\n" }

      before do
        expect(google_client).to receive(:execute).with(
          api_method: 'DELETE API DESCRIPTION',
          parameters: anything
        ).and_return(delete_response)
      end

      it 'raises an exception' do
        expect{ call(threadable, group) }.to raise_error Threadable::ExternalServiceError, 'Removing user foo@bar.com from google group failed, status: 500, message: Resource Not Found: raindrift+hey@gmail.com'
      end
    end

  end

  context 'when the google group does not exist' do
    let(:list_response) { double(:list_response, status: 500, body: 'FOO MOM') }

    it 'raises an exception' do
      expect{ call(threadable, group) }.to raise_error Threadable::ExternalServiceError, 'Could not retrieve google group users for electronics@foo.com'
    end
  end
end
