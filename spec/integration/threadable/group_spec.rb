require 'spec_helper'

describe Threadable::Group do

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }

  describe "#destroy" do
    context 'when the group has messages' do
      let(:group) { organization.groups.find_by_slug('electronics') }

      context 'when the user is an owner' do
        before do
          sign_in_as 'alice@ucsd.example.com'
        end

        it 'destroys the group and updates the group_count cache for each conversation' do
          conversation = group.conversations.all.first
          count = conversation.conversation_record.groups_count
          group.destroy
          expect(organization.groups.find_by_slug('electronics')).to be_nil
          expect(conversation.conversation_record.reload.groups_count).to eq count - 1
        end
      end

      context 'when the user is not an owner' do
        before do
          sign_in_as 'tom@ucsd.example.com'
        end

        it 'denies the action' do
          expect { group.destroy }.to raise_error(Threadable::AuthorizationError, 'You are not authorized to remove groups that contain messages')
        end
      end
    end

    context 'when the group is empty' do
      let(:group) { organization.groups.find_by_slug('press')}

      context 'when the user is an owner' do
        before do
          sign_in_as 'alice@ucsd.example.com'
        end

        it 'destroys the group' do
          group.destroy
          expect(organization.groups.find_by_slug('press')).to be_nil
        end
      end

      context 'when the user is not an owner' do
        before do
          sign_in_as 'tom@ucsd.example.com'
        end

        it 'destroys the group' do
          group.destroy
          expect(organization.groups.find_by_slug('press')).to be_nil
        end
      end
    end
  end

  describe '#google_sync=' do
    context 'when enabling google sync' do
      let(:alice) { organization.members.find_by_email_address('alice@ucsd.example.com')}
      let(:alice_as_user) { Threadable::User.new(threadable, alice.user_record) }
      let(:bob) { organization.members.find_by_email_address('bob@ucsd.example.com')}
      let(:group) { organization.groups.find_by_slug('electronics') }

      let(:google_client) { double(:google_client, authorization: double(:authorization), discovered_api: google_directory_api) }
      let(:google_directory_api) { double(:google_directory_api, groups: directory_api_groups)}
      let(:directory_api_groups) { double(:directory_api_groups, get: 'GET API DESCRIPTION', insert: 'INSERT API DESCRIPTION') }

      before do
        GoogleSyncWorker.sidekiq_options unique: false

        alice.external_authorizations.add_or_update!(
          provider: 'google_oauth2',
          token: 'foo',
          refresh_token: 'moar foo',
          name: 'Alice Neilson',
          email_address: 'alice@foo.com',
          domain: 'foo.com',
        )

        sign_in_as 'bob@ucsd.example.com'
        group.update(alias_email_address: '"Electronics for Jesus" <electronics@foo.com>')

        organization.google_user = alice
        expect(group).to receive(:client_for).with(alice_as_user).and_return(google_client)
        group.stub(:directory_api).and_return(google_directory_api)
        expect(google_client).to receive(:execute).with(api_method: 'GET API DESCRIPTION', parameters: {'groupKey' => 'electronics@foo.com' }).and_return(api_response)
        drain_background_jobs!
      end

      after do
        GoogleSyncWorker.sidekiq_options unique: true
      end

      context 'when the group can be found on their google apps domain' do
        let(:api_response) { double(:api_response, status: 200, body: 'RESPONSE JSON') }

        it 'enables sync, sets the sync user, and synchronizes the users' do
          expect_any_instance_of(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).with(anything, group)

          group.google_sync = true
          drain_background_jobs!
          expect(group.reload.google_sync?).to be_true
        end

        it 'enables sync and sets the sync user when called via update' do
          expect_any_instance_of(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).with(anything, group)

          group.update(google_sync: true)
          drain_background_jobs!
          expect(group.reload.google_sync?).to be_true
        end

        context 'when disabling google sync' do
          it 'removes the link to the google sync user' do
            expect_any_instance_of(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).with(anything, group)
            group.google_sync = true
            drain_background_jobs!
            expect(group.reload.google_sync?).to be_true
            group.google_sync = false
            drain_background_jobs!
            expect(group.reload.google_sync?).to be_false
          end
        end
      end

      context 'when the group can not be found on their google apps domain' do
        let(:api_response) { double(:api_response, status: 404, body: 'RESPONSE JSON') }
        let(:api_insert_response) { double(:api_insert_response, status: 200, body: 'RESPONSE JSON') }
        let(:group_insert_parameters) do
          {
            'email' => 'electronics@foo.com',
            'name' => 'Electronics on Threadable',
            'description' => 'This group enables Google Apps services sync for Electronics on Threadable / Soldering and wires and stuff!'
          }
        end

        before do
          expect(google_client).to receive(:execute).
            with(api_method: 'INSERT API DESCRIPTION', body_object: group_insert_parameters).
            and_return(api_insert_response)
        end

        it 'creates the group, enables sync, and sets the sync user' do
          expect_any_instance_of(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).with(anything, group)

          group.google_sync = true
          drain_background_jobs!
          expect(group.reload.google_sync?).to be_true
        end

        context 'when group creation fails' do
          let(:api_insert_response) { double(:api_insert_response, status: 500, body: 'RESPONSE JSON') }

          it 'raises an exception' do
            expect{ group.google_sync = true }.to raise_error Threadable::ExternalServiceError, 'Creating proxy google group failed (500): (no error message found)'
          end
        end
      end

      context 'when searching for the group fails' do
        let(:api_response) { double(:api_response, status: 500, body: 'RESPONSE JSON') }

        it 'raises an exception' do
          expect{ group.google_sync = true }.to raise_error Threadable::ExternalServiceError, 'Searching for google group failed (500): (no error message found)'
        end
      end
    end
  end
end
