require 'spec_helper'

describe Ability, :type => :request do

  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:organization_members) { organization.members }
  let(:member) { organization.members.current_member}
  let(:group) { organization.groups.find_by_slug('electronics') }
  let(:group_members) { group.members }
  let(:tom) { organization.members.find_by_email_address('tom@ucsd.example.com')}

  describe 'for owners' do
    before do
      sign_in_as 'alice@ucsd.example.com'
    end

    describe 'organization' do
      it 'can do everything' do
        expect(member.can?(:make_owners_for,             organization)).to be_truthy
        expect(member.can?(:change_settings_for,         organization)).to be_truthy
        expect(member.can?(:remove_non_empty_group_from, organization)).to be_truthy
        expect(member.can?(:be_google_user_for,          organization)).to be_truthy
        expect(member.can?(:create,                      organization_members)).to be_truthy
        expect(member.can?(:delete,                      organization_members)).to be_truthy
        expect(member.can?(:change_delivery_for,         organization.members.find_by_user_id(tom.id))).to be_truthy
      end
    end

    describe 'group' do
      it 'can do almost everything' do
        expect(member.can?(:set_google_sync_for, group)).to be_truthy
        expect(member.can?(:change_settings_for, group)).to be_truthy
        expect(member.can?(:create,              group_members)).to be_truthy
        expect(member.can?(:delete,              group_members)).to be_truthy
        expect(member.can?(:change_delivery_for, group.members.find_by_user_id(tom.id))).to be_truthy
      end

      context 'when the organization is free' do
        before do
          organization.organization_record.update_attribute(:plan, :free)
        end

        it 'cannot make private groups' do
          expect(member.can?(:make_private, organization.groups)).to be_falsy
        end
      end

      context 'when the organization is paid' do
        before do
          organization.organization_record.update_attribute(:plan, :paid)
        end

        it 'cannot make private groups' do
          expect(member.can?(:make_private, organization.groups)).to be_truthy
        end
      end
    end
  end

  describe 'for members' do
    let(:bethany) { organization.members.find_by_email_address('bethany@ucsd.example.com')}

    before do
      sign_in_as 'bethany@ucsd.example.com'
    end

    describe 'organization' do
      it 'can do nothing' do
        expect(member.can?(:make_owners_for,             organization)).to be_falsy
        expect(member.can?(:change_settings_for,         organization)).to be_falsy
        expect(member.can?(:remove_non_empty_group_from, organization)).to be_falsy
        expect(member.can?(:be_google_user_for,          organization)).to be_falsy
      end

      context 'when the org allows changing org membership' do
        before do
          organization.organization_record.update_attribute(:organization_membership_permission, 0)
        end

        it 'can add to the org membership' do
          expect(member.can?(:change_delivery_for, organization.members.find_by_user_id(tom.id))).to be_truthy
          expect(member.can?(:create, organization_members)).to be_truthy
          expect(member.can?(:delete, organization_members)).to be_falsy
        end
      end

      context 'when the org does not allow changing org membership' do
        before do
          organization.organization_record.update_attribute(:organization_membership_permission, 1)
        end

        it 'cannot add to the org membership' do
          expect(member.can?(:change_delivery_for, organization.members.find_by_user_id(tom.id))).to be_falsy
          expect(member.can?(:create, organization_members)).to be_falsy
          expect(member.can?(:delete, organization_members)).to be_falsy
        end
      end
    end

    describe 'group' do
      it 'cannot change the google user' do
        expect(member.can?(:set_google_sync_for, group)).to be_falsy
      end

      context 'when the organization is free' do
        before do
          organization.organization_record.update_attribute(:plan, :free)
        end

        it 'cannot make private groups' do
          expect(member.can?(:make_private, organization.groups)).to be_falsy
        end
      end

      context 'when the organization is paid' do
        before do
          organization.organization_record.update_attribute(:plan, :paid)
        end

        it 'cannot make private groups' do
          expect(member.can?(:make_private, organization.groups)).to be_truthy
        end
      end

      context 'when the org allows changing group settings' do
        before do
          organization.organization_record.update_attribute(:group_settings_permission, 0)
        end

        it 'can change the group settings' do
          expect(member.can?(:change_settings_for, group)).to be_truthy
        end
      end

      context 'when the org does not allow changing group settings' do
        before do
          organization.organization_record.update_attribute(:group_settings_permission, 1)
        end

        it 'cannot change the group settings' do
          expect(member.can?(:change_settings_for, group)).to be_falsy
        end
      end

      context 'when the org allows changing group membership' do
        before do
          organization.organization_record.update_attribute(:group_membership_permission, 0)
        end

        it 'can change the group membership' do
          expect(member.can?(:create, group_members)).to be_truthy
          expect(member.can?(:delete, group_members)).to be_truthy
          expect(member.can?(:change_delivery_for, group.members.find_by_user_id(tom.id))).to be_truthy
        end
      end

      context 'when the org does not allow changing group membership' do
        before do
          organization.organization_record.update_attribute(:group_membership_permission, 1)
        end

        it 'can change the group membership' do
          expect(member.can?(:create, group_members)).to be_falsy
          expect(member.can?(:delete, group_members)).to be_falsy
          expect(member.can?(:change_delivery_for, group.members.find_by_user_id(tom.id))).to be_falsy
          expect(member.can?(:change_delivery_for, group.members.find_by_user_id(bethany.id))).to be_truthy
        end
      end
    end

  end
end
