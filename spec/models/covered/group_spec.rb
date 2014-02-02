require 'spec_helper'

describe Covered::Group do

  let :organization_record do
    double(:organization_record,
      id: 5678,
      email_address_username: 'my-project',
      name: 'My Project'
    )
  end

  let :group_record do
    double(:group_record,
      id: 1234,
      organization_id: 5,
      name: 'thing factory',
      email_address_tag: 'thing-factory',
      organization: organization_record
    )
  end
  let(:group){ described_class.new(covered, group_record) }
  subject{ group }

  it { should have_constant :Members }
  it { should have_constant :Conversations }
  it { should have_constant :Tasks }

  it { should delegate(:id                ).to(:group_record) }
  it { should delegate(:to_param          ).to(:group_record) }
  it { should delegate(:name              ).to(:group_record) }
  it { should delegate(:email_address_tag ).to(:group_record) }
  it { should delegate(:errors            ).to(:group_record) }
  it { should delegate(:new_record?       ).to(:group_record) }
  it { should delegate(:persisted?        ).to(:group_record) }
  it { should delegate(:subject_tag       ).to(:group_record) }
  it { should delegate(:destroy           ).to(:group_record) }
  it { should delegate(:auto_join         ).to(:group_record) }

  describe 'model_name' do
    subject{ described_class }
    its(:model_name){ should == ::Group.model_name }
  end

  its(:organization_record          ){ should eq organization_record }
  its(:email_address                ){ should eq "my-project+thing-factory@127.0.0.1" }
  its(:task_email_address           ){ should eq "my-project+thing-factory+task@127.0.0.1" }
  its(:formatted_email_address      ){ should eq %("My Project: thing factory" <my-project+thing-factory@127.0.0.1>) }
  its(:formatted_task_email_address ){ should eq %("My Project: thing factory Tasks" <my-project+thing-factory+task@127.0.0.1>) }

  its(:members      ){ should be_a Covered::Group::Members }
  its(:conversations){ should be_a Covered::Group::Conversations }
  its(:tasks        ){ should be_a Covered::Group::Tasks }

  its(:inspect){ should eq %(#<Covered::Group group_id: 1234, name: "thing factory">) }
end
