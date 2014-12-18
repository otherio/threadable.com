require 'spec_helper'

describe Threadable::Group, :type => :model do

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
    allow(group.organization).to receive(:email_domains).and_return(double(:email_domains, outgoing: nil))
  end

  it { is_expected.to have_constant :Members }
  it { is_expected.to have_constant :Conversations }
  it { is_expected.to have_constant :Tasks }

  it { is_expected.to delegate(:id                 ).to(:group_record) }
  it { is_expected.to delegate(:to_param           ).to(:group_record) }
  it { is_expected.to delegate(:name               ).to(:group_record) }
  it { is_expected.to delegate(:email_address_tag  ).to(:group_record) }
  it { is_expected.to delegate(:errors             ).to(:group_record) }
  it { is_expected.to delegate(:new_record?        ).to(:group_record) }
  it { is_expected.to delegate(:persisted?         ).to(:group_record) }
  it { is_expected.to delegate(:subject_tag        ).to(:group_record) }
  it { is_expected.to delegate(:auto_join?         ).to(:group_record) }
  it { is_expected.to delegate(:non_member_posting ).to(:group_record) }
  it { is_expected.to delegate(:alias_email_address).to(:group_record) }
  it { is_expected.to delegate(:description        ).to(:group_record) }
  it { is_expected.to delegate(:google_sync?       ).to(:group_record) }
  it { is_expected.to delegate(:primary?           ).to(:group_record) }
  it { is_expected.to delegate(:private?           ).to(:group_record) }

  describe 'model_name' do
    subject{ described_class }

    describe '#model_name' do
      subject { super().model_name }
      it { is_expected.to eq(::Group.model_name) }
    end
  end

  describe '#organization_record' do
    subject { super().organization_record }
    it { is_expected.to eq organization_record }
  end

  describe '#email_address' do
    subject { super().email_address }
    it { is_expected.to eq "thing-factory@my-project.localhost" }
  end

  describe '#task_email_address' do
    subject { super().task_email_address }
    it { is_expected.to eq "thing-factory+task@my-project.localhost" }
  end

  describe '#formatted_email_address' do
    subject { super().formatted_email_address }
    it { is_expected.to eq %("My Project: thing factory" <thing-factory@my-project.localhost>) }
  end

  describe '#formatted_task_email_address' do
    subject { super().formatted_task_email_address }
    it { is_expected.to eq %("My Project: thing factory Tasks" <thing-factory+task@my-project.localhost>) }
  end

  describe '#members' do
    subject { super().members }
    it { is_expected.to be_a Threadable::Group::Members }
  end

  describe '#conversations' do
    subject { super().conversations }
    it { is_expected.to be_a Threadable::Group::Conversations }
  end

  describe '#tasks' do
    subject { super().tasks }
    it { is_expected.to be_a Threadable::Group::Tasks }
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq %(#<Threadable::Group group_id: 1234, name: "thing factory">) }
  end

  context 'with an alias address defined' do
    let(:alias_email_address) { %("My Elsewhere" <elsewhere@foo.com>) }

    describe '#email_address' do
      subject { super().email_address }
      it { is_expected.to eq "elsewhere@foo.com" }
    end

    describe '#task_email_address' do
      subject { super().task_email_address }
      it { is_expected.to eq "elsewhere-task@foo.com" }
    end

    describe '#internal_email_address' do
      subject { super().internal_email_address }
      it { is_expected.to eq "thing-factory@my-project.localhost" }
    end

    describe '#internal_task_email_address' do
      subject { super().internal_task_email_address }
      it { is_expected.to eq "thing-factory+task@my-project.localhost" }
    end

    describe '#formatted_email_address' do
      subject { super().formatted_email_address }
      it { is_expected.to eq %(My Elsewhere <elsewhere@foo.com>) }
    end

    describe '#formatted_task_email_address' do
      subject { super().formatted_task_email_address }
      it { is_expected.to eq %(My Elsewhere Tasks <elsewhere-task@foo.com>) }
    end
  end
end
