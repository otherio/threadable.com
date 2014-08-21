require 'spec_helper'

describe Threadable::Group::Conversations, :type => :model do
  let(:organization) { double(:organization, id: 1, threadable: threadable) }
  let :group do
    double(:group,
      organization: organization,
      threadable: threadable,
      id: 2,
    )
  end

  let(:conversations) { described_class.new(group) }
  subject {conversations}

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
    it { is_expected.to eq '#<Threadable::Group::Conversations organization_id: 1 group_id: 2>' }
  end
end
