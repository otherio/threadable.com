require 'spec_helper'

describe Threadable::Organization::Settings, :type => :request do

  let(:organization){ threadable.organizations.find_by_slug('raceteam') }

  it 'defines instance methods' do
    expect(organization.settings.group_membership_permission).to eq :member
  end

  describe '#set' do
    context 'when the org is unpaid' do
      before do
        organization.organization_record.update_attribute(:plan, :free)
      end

      it 'is not settable' do
        expect(organization.settings.settable?(:group_membership_permission)).to be_falsy
      end

      it 'raises an error when trying to set it' do
        expect{organization.settings.set(:group_membership_permission, :owner)}.to raise_error Threadable::AuthorizationError, 'You cannot set that parameter with your current plan'
      end
    end

    context 'when the org is paid' do
      before do
        organization.organization_record.update_attribute(:plan, :paid)
      end

      it 'is settable' do
        expect(organization.settings.settable?(:group_membership_permission)).to be_truthy
      end

      it 'sets the value' do
        organization.settings.set(:group_membership_permission, :owner)
        expect(organization.settings.group_membership_permission).to eq :owner
      end
    end
  end

  describe '#get' do
    before do
      organization.organization_record.update_attribute(:group_membership_permission, 1)
    end

    context 'when the org is unpaid' do
      before do
        organization.organization_record.update_attribute(:plan, :free)
      end

      it 'is not gettable' do
        expect(organization.settings.gettable?(:group_membership_permission)).to be_falsy
      end

      it 'reverts the default value specified in the model' do
        expect(organization.settings.group_membership_permission).to eq :member
      end
    end

    context 'when the org is paid' do
      before do
        organization.organization_record.update_attribute(:plan, :paid)
      end

      it 'is gettable' do
        expect(organization.settings.gettable?(:group_membership_permission)).to be_truthy
      end

      it 'returns the stored value' do
        expect(organization.settings.group_membership_permission).to eq :owner
      end
    end
  end

end
