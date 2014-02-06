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

  its(:email_address                ){ should eq "C02-cleaners@127.0.0.1" }
  its(:task_email_address           ){ should eq "C02-cleaners+task@127.0.0.1" }
  its(:formatted_email_address      ){ should eq "C02 Cleaners <C02-cleaners@127.0.0.1>" }
  its(:formatted_task_email_address ){ should eq "C02 Cleaners Tasks <C02-cleaners+task@127.0.0.1>" }
  its(:list_id                      ){ should eq "C02 Cleaners <C02-cleaners.127.0.0.1>" }

  its(:members)        { should be_a Threadable::Organization::Members        }
  its(:conversations)  { should be_a Threadable::Organization::Conversations  }
  its(:messages)       { should be_a Threadable::Organization::Messages       }
  its(:tasks)          { should be_a Threadable::Organization::Tasks          }
  its(:incoming_emails){ should be_a Threadable::Organization::IncomingEmails }
  its(:held_messages)  { should be_a Threadable::Organization::HeldMessages   }
  its(:groups)         { should be_a Threadable::Organization::Groups         }

  its(:inspect){ should eq %(#<Threadable::Organization organization_id: 5479, name: "C02 Cleaners">) }

  its(:class){ should include Threadable::Conversation::Scopes }

  describe 'update' do
    it 'calls Threadable::Organization::Update' do
      attributes = {some:'updates'}
      expect(Threadable::Organization::Update).to receive(:call).with(organization, attributes).and_return(45)
      expect(organization.update(attributes)).to eq 45
    end
  end


  describe 'current_member' do
    when_not_signed_in do
      it 'raises a Threadable::AuthorizationError' do
        expect{ subject.current_member }.to raise_error Threadable::AuthorizationError
      end
    end
    when_signed_in do
      it 'returns members.me' do
        member = double(:member)
        expect(subject.members).to receive(:me).once.and_return(member)
        expect(subject.current_member).to be member
        expect(subject.current_member).to be member
      end
    end
  end

  describe '#leave!' do
    when_not_signed_in do
      it 'raises a Threadable::AuthorizationError' do
        expect{ subject.leave! }.to raise_error Threadable::AuthorizationError
      end
    end
    when_signed_in do
      it 'should return the current users member' do
        expect(subject.members).to receive(:remove).with(user: current_user)
        subject.leave!
      end
    end
  end

end
