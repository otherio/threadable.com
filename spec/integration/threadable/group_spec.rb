require 'spec_helper'

describe Threadable::Group, :type => :request do

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:group) { organization.groups.find_by_slug('electronics') }

  describe 'email addresses' do
    let(:email_domain) { organization.email_domains.find_by_domain('raceteam.com') }

    context 'with an outgoing email domain' do
      before do
        sign_in_as 'alice@ucsd.example.com'
        email_domain.outgoing!
      end

      it 'returns an address using the email domain' do
        expect(group.formatted_email_address).to eq '"UCSD Electric Racing: Electronics" <electronics@raceteam.com>'
        expect(group.formatted_task_email_address).to eq '"UCSD Electric Racing: Electronics Tasks" <electronics+task@raceteam.com>'
        expect(group.internal_email_address).to eq 'electronics@raceteam.localhost'
      end

      context 'with an alias email address defined' do
        before do
          group.update(alias_email_address: 'My Elsewhere <my@elsewhere.com>')
        end

        it 'returns the alias email address' do
          expect(group.formatted_email_address).to eq 'My Elsewhere <my@elsewhere.com>'
        end
      end
    end
  end

  describe '#update' do
    before do
      sign_in_as 'bethany@ucsd.example.com'
    end

    context 'when the current user has permission to change group settings' do
      it 'updates the group' do
        group.update(alias_email_address: 'foo@bar.com')
        expect(group.alias_email_address).to eq 'foo@bar.com'
      end
    end

    context 'when the current user does not have permission to change group settings' do
      before do
        organization.organization_record.update_attribute(:group_settings_permission, 1)
      end

      it 'raises an error' do
        expect { group.update(alias_email_address: 'foo@bar.com') }.to raise_error Threadable::AuthorizationError, 'You do not have permission to change settings for this group'
      end
    end

    context 'when the group is private' do
      let(:group_record) { ::Group.where(email_address_tag: 'leaders').first }
      let(:group) { Threadable::Group.new(threadable, group_record) }

      context 'when the user is an owner' do
        before do
          sign_in_as 'alice@ucsd.example.com'
          group.members.remove(organization.members.find_by_email_address('alice@ucsd.example.com'))
        end

        it 'updates the group' do
          group.update(alias_email_address: 'foo@bar.com')
          expect(group.alias_email_address).to eq 'foo@bar.com'
        end
      end

      context 'when the user is a member' do
        context 'when the user is in the group' do
          before do
            sign_in_as 'tom@ucsd.example.com'
          end

          it 'updates the group' do
            group.update(alias_email_address: 'foo@bar.com')
            expect(group.alias_email_address).to eq 'foo@bar.com'
          end
        end

        context 'when the user is not in the group' do
          before do
            sign_in_as 'bethany@ucsd.example.com'
          end

          it 'raises an error' do
            expect { group.update(alias_email_address: 'foo@bar.com') }.to raise_error Threadable::AuthorizationError, 'You do not have permission to change settings for this group'
          end
        end
      end
    end

    context 'when the org is free' do
      before do
        organization.organization_record.update_attribute(:plan, :free)
      end

      it 'does not allow you to make the group private' do
        expect {group.update(private: true)}.to raise_error Threadable::AuthorizationError, 'You do not have permission to make private groups for this organization'
      end

      it 'does allow you to make the group un-private' do
        group.group_record.update_attribute(:private, true)
        group.update(private: false)
        expect(group.private?).to be_falsy
      end
    end

    context 'when the org is paid' do
      before do
        organization.organization_record.update_attribute(:plan, :paid)
      end

      it 'allows you to make the group private' do
        group.update(private: true)
        expect(group.private?).to be_truthy
      end
    end
  end

  describe '#admin_update' do
    context 'when the current user has permission to change group settings' do
      before do
        sign_in_as 'ian@other.io'
      end

      it 'updates the group' do
        group.admin_update(alias_email_address: 'foo@bar.com')
        expect(group.alias_email_address).to eq 'foo@bar.com'
      end
    end

    context 'when the current user does not have permission to change group settings' do
      before do
        sign_in_as 'alice@ucsd.example.com'
      end

      it 'raises an error' do
        expect { group.admin_update(alias_email_address: 'foo@bar.com') }.to raise_error Threadable::AuthorizationError, 'You do not have permission to change settings for this group'
      end
    end
  end

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

    context "when it's the primary group" do
      let(:group) { organization.groups.find_by_slug('raceteam')}

      before do
        sign_in_as 'alice@ucsd.example.com'
      end

      it "raises an exception" do
        expect{ group.destroy }.to raise_error Threadable::AuthorizationError, 'The primary group cannot be removed'
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

      let(:google_groups_settings_api) { double(:google_groups_settings_api, groups: groups_settings_api_groups)}
      let(:groups_settings_api_groups) { double(:groups_settings_api_groups, update: 'SETTINGS UPDATE API DESCRIPTION') }

      let(:api_settings_response) { double(:api_response, status: 200, body: 'SETTINGS RESPONSE JSON') }

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
        allow(group).to receive(:directory_api).and_return(google_directory_api)
        allow(group).to receive(:groups_settings_api).and_return(google_groups_settings_api)
        expect(google_client).to receive(:execute).with(api_method: 'GET API DESCRIPTION', parameters: {'groupKey' => 'electronics@foo.com' }).and_return(api_response)
        allow(google_client).to receive(:execute).with(
          api_method: 'SETTINGS UPDATE API DESCRIPTION',
          parameters: anything,
          body_object: anything,
        ).and_return(api_settings_response)
        drain_background_jobs!

        sign_in_as 'alice@ucsd.example.com'
      end

      after do
        GoogleSyncWorker.sidekiq_options unique: true
      end

      context 'when the group can be found on their google apps domain' do
        let(:api_response) { double(:api_response, status: 200, body: 'RESPONSE JSON') }

        it 'enables sync, sets the sync user, sets permissions, and synchronizes the users' do
          expect_any_instance_of(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).with(anything, group)

          expect(google_client).to receive(:execute).with(
            api_method: 'SETTINGS UPDATE API DESCRIPTION',
            parameters: {'groupUniqueId' => 'electronics@foo.com' },
            body_object: {
              "whoCanViewMembership" => "ALL_IN_DOMAIN_CAN_VIEW",
              "whoCanViewGroup"      => "ALL_IN_DOMAIN_CAN_VIEW",
              "whoCanPostMessage"    => "ALL_IN_DOMAIN_CAN_POST",
            }
          ).and_return(api_settings_response)

          group.google_sync = true
          drain_background_jobs!
          expect(group.reload.google_sync?).to be_truthy
        end

        it 'enables sync and sets the sync user when called via update' do
          expect_any_instance_of(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).with(anything, group)

          group.update(google_sync: true)
          drain_background_jobs!
          expect(group.reload.google_sync?).to be_truthy
        end

        context 'when disabling google sync' do
          it 'removes the link to the google sync user' do
            expect_any_instance_of(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).with(anything, group)
            group.google_sync = true
            drain_background_jobs!
            expect(group.reload.google_sync?).to be_truthy
            group.google_sync = false
            drain_background_jobs!
            expect(group.reload.google_sync?).to be_falsey
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

        it 'creates the group, enables sync, sets permissions, and sets the sync user' do
          expect_any_instance_of(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).with(anything, group)

          expect(google_client).to receive(:execute).with(
            api_method: 'SETTINGS UPDATE API DESCRIPTION',
            parameters: {'groupUniqueId' => 'electronics@foo.com' },
            body_object: {
              "whoCanViewMembership" => "ALL_IN_DOMAIN_CAN_VIEW",
              "whoCanViewGroup"      => "ALL_IN_DOMAIN_CAN_VIEW",
              "whoCanPostMessage"    => "ALL_IN_DOMAIN_CAN_POST",
            }
          ).and_return(api_settings_response)

          group.google_sync = true
          drain_background_jobs!
          expect(group.reload.google_sync?).to be_truthy
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

      context 'when searching for the group fails' do
        let(:api_response) { double(:api_response, status: 200, body: 'RESPONSE JSON') }
        let(:api_settings_response) { double(:api_settings_response, status: 500, body: 'SETTINGS RESPONSE JSON') }

        it 'raises an exception' do
          expect{ group.google_sync = true }.to raise_error Threadable::ExternalServiceError, 'Updating permissions for proxy google group failed (500): (no error message found)'
        end
      end
    end
  end
end
