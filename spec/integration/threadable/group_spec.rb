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
      let(:group) { organization.groups.find_by_slug('electronics') }

      before do
        alice.external_authorizations.add_or_update!(
          provider: 'google_oauth2',
          token: 'foo',
          name: 'Alice Neilson',
          email_address: 'alice@foo.com',
          domain: 'foo.com',
        )

        sign_in_as 'alice@ucsd.example.com'
      end

      context 'when the user has proper google credentials' do
        it 'links the current user to the group' do
          group.google_sync = true
          expect(group.reload.google_sync_user).to eq alice
        end

        context 'when the group can be found on their google apps domain' do
        end

        context 'when the group can not be found on their google apps domain' do
          it 'creates the group'

          context 'when group creation fails' do
            it 'does not enable sync'
          end
        end
      end

      context 'when the user does not have google credentials' do
      end
    end

    context 'when disabling google sync' do
      it 'removes the link to the google sync user'
    end
  end
end
