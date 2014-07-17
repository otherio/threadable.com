require 'spec_helper'

describe Threadable::Group do

  let :organization_record do
    double(:organization_record,
      id: 5678,
      email_address_username: 'my-project',
      name: 'My Project',
    )
  end

  let :group_record do
    double(:group_record,
      id: 1234,
      organization_id: 5,
      name: 'thing factory',
      email_address_tag: 'thing-factory',
      organization: organization_record,
      alias_email_address: alias_email_address,
    )
  end
  let(:group){ described_class.new(threadable, group_record) }
  let(:alias_email_address) { nil }
  subject{ group }

  before do
    group.organization.stub(:email_domains).and_return(double(:email_domains, outgoing: nil))
  end

  it { should have_constant :Members }
  it { should have_constant :Conversations }
  it { should have_constant :Tasks }

  it { should delegate(:id                 ).to(:group_record) }
  it { should delegate(:to_param           ).to(:group_record) }
  it { should delegate(:name               ).to(:group_record) }
  it { should delegate(:email_address_tag  ).to(:group_record) }
  it { should delegate(:errors             ).to(:group_record) }
  it { should delegate(:new_record?        ).to(:group_record) }
  it { should delegate(:persisted?         ).to(:group_record) }
  it { should delegate(:subject_tag        ).to(:group_record) }
  it { should delegate(:auto_join?         ).to(:group_record) }
  it { should delegate(:hold_messages?     ).to(:group_record) }
  it { should delegate(:alias_email_address).to(:group_record) }
  it { should delegate(:description        ).to(:group_record) }
  it { should delegate(:google_sync?       ).to(:group_record) }
  it { should delegate(:primary?           ).to(:group_record) }

  describe 'model_name' do
    subject{ described_class }
    its(:model_name){ should == ::Group.model_name }
  end

  its(:organization_record          ){ should eq organization_record }
  its(:email_address                ){ should eq "thing-factory@my-project.localhost" }
  its(:task_email_address           ){ should eq "thing-factory+task@my-project.localhost" }
  its(:formatted_email_address      ){ should eq %("My Project: thing factory" <thing-factory@my-project.localhost>) }
  its(:formatted_task_email_address ){ should eq %("My Project: thing factory Tasks" <thing-factory+task@my-project.localhost>) }

  its(:members      ){ should be_a Threadable::Group::Members }
  its(:conversations){ should be_a Threadable::Group::Conversations }
  its(:tasks        ){ should be_a Threadable::Group::Tasks }

  its(:inspect){ should eq %(#<Threadable::Group group_id: 1234, name: "thing factory">) }

  context 'with an alias address defined' do
    let(:alias_email_address) { %("My Elsewhere" <elsewhere@foo.com>) }

    its(:email_address                ){ should eq "elsewhere@foo.com" }
    its(:task_email_address           ){ should eq "elsewhere-task@foo.com" }
    its(:internal_email_address       ){ should eq "thing-factory@my-project.localhost" }
    its(:internal_task_email_address  ){ should eq "thing-factory+task@my-project.localhost" }
    its(:formatted_email_address      ){ should eq %(My Elsewhere <elsewhere@foo.com>) }
    its(:formatted_task_email_address ){ should eq %(My Elsewhere Tasks <elsewhere-task@foo.com>) }
  end
end
