require 'spec_helper'

describe Covered::Project do

  let :project_record do
    double(:project_record,
      id: 5479,
      name: 'C02 Cleaners',
      email_address_username: 'C02-cleaners',
    )
  end
  let(:project){ described_class.new(covered, project_record) }
  subject{ project }

  it { should have_constant :Update }
  it { should have_constant :Members }
  it { should have_constant :Member }
  it { should have_constant :Conversations }
  it { should have_constant :Messages }
  it { should have_constant :Tasks }

  it { should delegate(:id                    ).to(:project_record) }
  it { should delegate(:to_param              ).to(:project_record) }
  it { should delegate(:name                  ).to(:project_record) }
  it { should delegate(:short_name            ).to(:project_record) }
  it { should delegate(:slug                  ).to(:project_record) }
  it { should delegate(:email_address_username).to(:project_record) }
  it { should delegate(:subject_tag           ).to(:project_record) }
  it { should delegate(:description           ).to(:project_record) }
  it { should delegate(:errors                ).to(:project_record) }
  it { should delegate(:new_record?           ).to(:project_record) }
  it { should delegate(:persisted?            ).to(:project_record) }

  describe 'model_name' do
    subject{ described_class }
    its(:model_name){ should == ::Project.model_name }
  end

  its(:email_address                ){ should eq "C02-cleaners@127.0.0.1" }
  its(:task_email_address           ){ should eq "C02-cleaners+task@127.0.0.1" }
  its(:formatted_email_address      ){ should eq "C02 Cleaners <C02-cleaners@127.0.0.1>" }
  its(:formatted_task_email_address ){ should eq "C02 Cleaners Tasks <C02-cleaners+task@127.0.0.1>" }
  its(:list_id                      ){ should eq "C02-cleaners.127.0.0.1" }
  its(:formatted_list_id            ){ should eq "C02 Cleaners <C02-cleaners.127.0.0.1>" }

  its(:members      ){ should be_a Covered::Project::Members }
  its(:conversations){ should be_a Covered::Project::Conversations }
  its(:tasks        ){ should be_a Covered::Project::Tasks }
  its(:messages     ){ should be_a Covered::Project::Messages }

  its(:inspect){ should eq %(#<Covered::Project project_id: 5479, name: "C02 Cleaners">) }

  describe 'update' do
    it 'calls Covered::Project::Update' do
      attributes = {some:'updates'}
      expect(Covered::Project::Update).to receive(:call).with(project, attributes).and_return(45)
      expect(project.update(attributes)).to eq 45
    end
  end

end
