require 'spec_helper'

describe Threadable::Organization do

  let :organization_record do
    double(:organization_record,
      id: 5479,
      name: 'C02 Cleaners',
      email_address_username: 'C02-cleaners',
    )
  end

  let(:organization){ described_class.new(threadable, organization_record) }
  subject{ organization }

  it { should have_constant :Update }
  it { should have_constant :Members }
  it { should have_constant :Member }
  it { should have_constant :Conversations }
  it { should have_constant :Messages }
  it { should have_constant :Tasks }

  it { should delegate(:id                    ).to(:organization_record) }
  it { should delegate(:to_param              ).to(:organization_record) }
  it { should delegate(:name                  ).to(:organization_record) }
  it { should delegate(:short_name            ).to(:organization_record) }
  it { should delegate(:slug                  ).to(:organization_record) }
  it { should delegate(:email_address_username).to(:organization_record) }
  it { should delegate(:subject_tag           ).to(:organization_record) }
  it { should delegate(:description           ).to(:organization_record) }
  it { should delegate(:errors                ).to(:organization_record) }
  it { should delegate(:new_record?           ).to(:organization_record) }
  it { should delegate(:persisted?            ).to(:organization_record) }

  describe 'model_name' do
    subject{ described_class }
    its(:model_name){ should == ::Organization.model_name }
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
      organization.stub(:groups).and_return(groups)
    end

    its(:email_address                ){ should eq "C02-cleaners@localhost" }
    its(:task_email_address           ){ should eq "C02-cleaners+task@localhost" }
    its(:formatted_email_address      ){ should eq "C02 Cleaners <C02-cleaners@localhost>" }
    its(:formatted_task_email_address ){ should eq "C02 Cleaners Tasks <C02-cleaners+task@localhost>" }
    its(:list_id                      ){ should eq "C02 Cleaners <C02-cleaners.localhost>" }
  end

  its(:members)        { should be_a Threadable::Organization::Members        }
  its(:conversations)  { should be_a Threadable::Organization::Conversations  }
  its(:messages)       { should be_a Threadable::Organization::Messages       }
  its(:tasks)          { should be_a Threadable::Organization::Tasks          }
  its(:incoming_emails){ should be_a Threadable::Organization::IncomingEmails }
  its(:held_messages)  { should be_a Threadable::Organization::HeldMessages   }
  its(:groups)         { should be_a Threadable::Organization::Groups         }

  its(:inspect){ should eq %(#<Threadable::Organization organization_id: 5479, name: "C02 Cleaners">) }

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
