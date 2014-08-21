require 'spec_helper'

describe Threadable::Group::Tasks, :type => :model do

  let(:organization) { double(:organization, id: 1, threadable: threadable) }
  let :group do
    double(:group,
      organization: organization,
      threadable: threadable,
      id: 2,
    )
  end

  let(:tasks) { described_class.new(group) }
  subject {tasks}

  describe '#organization' do
    subject { super().organization }
    it { is_expected.to eq organization }
  end

  describe '#threadable' do
    subject { super().threadable }
    it { is_expected.to eq threadable }
  end

  describe '#inspect' do
    subject { super().inspect }
    it { is_expected.to eq '#<Threadable::Group::Tasks organization_id: 1 group_id: 2>' }
  end
end
