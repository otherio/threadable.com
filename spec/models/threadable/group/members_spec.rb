require 'spec_helper'

describe Threadable::Group::Members do
  let(:organization) { double(:organization, id: 1, threadable: threadable) }
  let :group do
    double(:group,
      organization: organization,
      threadable: threadable,
      id: 2,
    )
  end

  let(:members) { described_class.new(group) }
  subject {members}

  its(:threadable)      { should eq threadable }
  its(:inspect)      { should eq '#<Threadable::Group::Members organization_id: 1 group_id: 2>' }
end
