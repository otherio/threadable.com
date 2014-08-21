require 'spec_helper'

describe Threadable::Organization, :type => :model do

  let :organization_record do
    double(:organization_record,
      id: 5479,
      name: 'C02 Cleaners',
      email_address_username: 'C02-cleaners',
    )
  end

  let(:organization){ described_class.new(threadable, organization_record) }
  subject{ organization }

  it { is_expected.to have_constant :Update }
  it { is_expected.to have_constant :Members }
  it { is_expected.to have_constant :Member }
  it { is_expected.to have_constant :Conversations }
  it { is_expected.to have_constant :Messages }
  it { is_expected.to have_constant :Tasks }

  it { is_expected.to delegate(:id                    ).to(:organization_record) }
  it { is_expected.to delegate(:to_param              ).to(:organization_record) }
  it { is_expected.to delegate(:name                  ).to(:organization_record) }
  it { is_expected.to delegate(:short_name            ).to(:organization_record) }
  it { is_expected.to delegate(:slug                  ).to(:organization_record) }
  it { is_expected.to delegate(:email_address_username).to(:organization_record) }
  it { is_expected.to delegate(:subject_tag           ).to(:organization_record) }
  it { is_expected.to delegate(:description           ).to(:organization_record) }
  it { is_expected.to delegate(:errors                ).to(:organization_record) }
  it { is_expected.to delegate(:new_record?           ).to(:organization_record) }
  it { is_expected.to delegate(:persisted?            ).to(:organization_record) }

  describe 'model_name' do
    subject{ described_class }

    describe '#model_name' do
      subject { super().model_name }
      it { is_expected.to eq(::Organization.model_name) }
    end
  end

  describe 'email addresses' do
    let(:groups) { double(:groups, primary: primary_group) }
    let(:primary_group) do
      double(:primary_group,
        email_address:                "C02-cleaners@localhost",
        internal_email_address:       "C02-cleaners@localhost",
        task_email_address:           "C02-cleaners+task@localhost",
        internal_task_email_address:  "C02-cleaners+task@localhost",
        formatted_email_address:      "C02 Cleaners <C02-cleaners@localhost>",
        formatted_task_email_address: "C02 Cleaners Tasks <C02-cleaners+task@localhost>",
      )
    end

    before do
      allow(organization).to receive(:groups).and_return(groups)
    end

    describe '#email_address' do
      subject { super().email_address }
      it { is_expected.to eq "C02-cleaners@localhost" }
    end

    describe '#task_email_address' do
      subject { super().task_email_address }
      it { is_expected.to eq "C02-cleaners+task@localhost" }
    end

    describe '#formatted_email_address' do
      subject { super().formatted_email_address }
      it { is_expected.to eq "C02 Cleaners <C02-cleaners@localhost>" }
    end

    describe '#formatted_task_email_address' do
      subject { super().formatted_task_email_address }
      it { is_expected.to eq "C02 Cleaners Tasks <C02-cleaners+task@localhost>" }
    end

    describe '#list_id' do
      subject { super().list_id }
      it { is_expected.to eq "C02 Cleaners <C02-cleaners.localhost>" }
    end
  end

  describe '#members' do
    subject { super().members }
    it { is_expected.to be_a Threadable::Organization::Members        }
  end

  describe '#conversations' do
    subject { super().conversations }
    it { is_expected.to be_a Threadable::Organization::Conversations  }
  end

  describe '#messages' do
    subject { super().messages }
    it { is_expected.to be_a Threadable::Organization::Messages       }
  end

  describe '#tasks' do
    subject { super().tasks }
    it { is_expected.to be_a Threadable::Organization::Tasks          }
  end

  describe '#incoming_emails' do
    subject { super().incoming_emails }
    it { is_expected.to be_a Threadable::Organization::IncomingEmails }
  end

  describe '#held_messages' do
    subject { super().held_messages }
    it { is_expected.to be_a Threadable::Organization::HeldMessages   }
  end

  describe '#groups' do
    subject { super().groups }
    it { is_expected.to be_a Threadable::Organization::Groups         }
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq %(#<Threadable::Organization organization_id: 5479, name: "C02 Cleaners">) }
  end

  describe 'update' do
    let(:current_member) { double(:current_member) }
    it 'calls Threadable::Organization::Update' do
      attributes = {some:'updates'}
      expect(organization.members).to receive(:current_member).and_return current_member
      expect(current_member).to receive(:can?).with(:change_settings_for, organization).and_return true
      expect(Threadable::Organization::Update).to receive(:call).with(organization, attributes).and_return(45)
      expect(organization.update(attributes)).to eq 45
    end

    it 'fails when the member does not have permission' do
      attributes = {some:'updates'}
      expect(organization.members).to receive(:current_member).and_return current_member
      expect(current_member).to receive(:can?).with(:change_settings_for, organization).and_return false
      expect(Threadable::Organization::Update).to_not receive(:call)
      expect {organization.update(attributes)}.to raise_error(Threadable::AuthorizationError)
    end
  end

  describe 'admin_update' do
    it 'calls Threadable::Organization::Update' do
      attributes = {some:'updates'}
      expect(threadable.current_user).to receive(:admin?).and_return true
      expect(Threadable::Organization::Update).to receive(:call).with(organization, attributes).and_return(45)
      expect(organization.admin_update(attributes)).to eq 45
    end

    it 'fails when the user is not an admin' do
      attributes = {some:'updates'}
      expect(threadable.current_user).to receive(:admin?).and_return false
      expect(Threadable::Organization::Update).to_not receive(:call)
      expect {organization.admin_update(attributes)}.to raise_error(Threadable::AuthorizationError)
    end
  end

end
