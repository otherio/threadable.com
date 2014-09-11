require 'spec_helper'

describe Threadable::Group::Members, :type => :request do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:group){ organization.groups.find_by_email_address_tag!('electronics') }
  let(:members){ group.members }
  subject{ members }

  describe '#all' do
    it 'returns all the members of the group as Threadable::User instances' do
      expect( members.all ).to be_a Array
      expect( members.all.first ).to be_a Threadable::User
    end
  end

  describe '#all_with_email_addresses' do
    it 'returns all the members of the group as Threadable::User instances' do
      expect( members.all_with_email_addresses ).to be_a Array
      expect( members.all_with_email_addresses.first ).to be_a Threadable::User
    end
  end

  describe '#add' do
    context 'when signed in' do
      before do
        sign_in_as 'alice@ucsd.example.com'
      end

      context 'when the user is changing their own group record' do
        let(:member) { current_user }

        it 'does not send email' do
          expect( members ).to_not include member
          members.add member
          expect( members ).to include member

          drain_background_jobs!
          expect(sent_emails).to be_empty
        end

        context 'when the current user does not have permission to change group membership' do
          before do
            sign_in_as 'nadya@ucsd.example.com'
            organization.organization_record.update_attribute(:group_membership_permission, 1)
          end

          it 'still works' do
            expect( members ).to_not include member
            members.add member
            expect( members ).to include member
          end
        end
      end

      context 'when the user is changing the membership for another user' do
        let(:member) { organization.members.find_by_email_address('bob@ucsd.example.com') }

        it 'sends email' do
          expect(member.id).to_not eq current_user.id
          expect( members ).to_not include member
          members.add member
          expect( members ).to include member

          drain_background_jobs!
          expect(sent_emails.first.subject).to include 'I added you to Electronics on UCSD Electric Racing'
        end

        context 'when the current user does not have permission to change group membership' do
          before do
            sign_in_as 'nadya@ucsd.example.com'
            organization.organization_record.update_attribute(:group_membership_permission, 1)
          end

          it 'raises an exception' do
            expect { members.add member }.to raise_error Threadable::AuthorizationError, 'You do not have permission to change membership for this group'
          end
        end
      end
    end

    context 'when google sync is enabled' do
      let(:google_user) { organization.members.find_by_email_address('bob@ucsd.example.com').user_record }
      let(:new_member) { organization.members.find_by_email_address('jonathan@ucsd.example.com') }

      before do
        sign_in_as('alice@ucsd.example.com')
        group.group_record.update_attributes(
          google_sync: true
        )
        organization.update(google_user: google_user)

        GoogleSyncWorker.sidekiq_options unique: false
      end

      after { GoogleSyncWorker.sidekiq_options unique: true }

      it 'synchronizes the users' do
        expect_any_instance_of(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).with(anything, group)
        members.add new_member
        drain_background_jobs!
      end
    end

  end

  describe '#remove' do
    context 'when signed in' do
      before do
        sign_in_as 'tom@ucsd.example.com' # a member.
      end

      context 'when the user is changing their own group record' do
        let(:member) { current_user }

        it 'does not send email' do
          expect( members ).to include member
          members.remove member
          expect( members ).to_not include member
          drain_background_jobs!
          expect(sent_emails).to be_empty
        end

        context 'when the current user does not have permission to change group membership' do
          before do
            sign_in_as 'tom@ucsd.example.com'
            organization.organization_record.update_attribute(:group_membership_permission, 1)
          end

          it 'still works' do
            expect( members ).to include member
            members.remove member
            expect( members ).to_not include member
          end
        end
      end

      context 'when the user is changing the membership for another user' do
        let(:member) { organization.members.find_by_email_address('bethany@ucsd.example.com') }

        it 'sends email' do
          expect(member.id).to_not eq current_user.id
          expect( members ).to include member
          members.remove member
          expect( members ).to_not include member
          drain_background_jobs!
          expect(sent_emails.first.subject).to include 'I removed you from Electronics on UCSD Electric Racing'
        end

        context 'when the current user does not have permission to change group membership' do
          before do
            sign_in_as 'tom@ucsd.example.com'
            organization.organization_record.update_attribute(:group_membership_permission, 1)
          end

          it 'raises an exception' do
            expect { members.remove member }.to raise_error Threadable::AuthorizationError, 'You do not have permission to change membership for this group'
          end
        end
      end
    end

    context 'when google sync is enabled' do
      let(:google_user) { organization.members.find_by_email_address('bob@ucsd.example.com').user_record }
      let(:member_to_remove) { organization.members.find_by_email_address('jonathan@ucsd.example.com') }

      before do
        sign_in_as('alice@ucsd.example.com')
        group.group_record.update_attributes(
          google_sync: true,
        )
        organization.update(google_user: google_user)

        GoogleSyncWorker.sidekiq_options unique: false
      end

      after { GoogleSyncWorker.sidekiq_options unique: true }

      it 'synchronizes the users' do
        expect_any_instance_of(Threadable::Integrations::Google::GroupMembersSync).to receive(:call).with(anything, group)
        members.remove member_to_remove
        drain_background_jobs!
      end
    end
  end

  describe '#include?' do
    it 'returns true if the given user is in the group' do
      member_user_ids = members.all.map(&:user_id)
      organization.members.all.each do |user|
        if member_user_ids.include?(user.user_id)
          expect( members ).to include user
        else
          expect( members ).to_not include user
        end
      end
    end
  end

end
