require 'spec_helper'

describe Covered::Group::Conversations do
  let(:organization) { double(:organization, id: 1, covered: covered) }
  let :group do
    double(:group,
      organization: organization,
      covered: covered,
      id: 2,
    )
  end

  let(:conversations) { described_class.new(group) }
  subject {conversations}

  its(:organization) { should eq organization }
  its(:covered)      { should eq covered }
  its(:inspect)      { should eq '#<Covered::Group::Conversations organization_id: 1 group_id: 2>' }
end
