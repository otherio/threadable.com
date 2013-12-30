require 'spec_helper'

describe Covered::Group::Members do
  let(:organization) { double(:organization, id: 1, covered: covered) }
  let :group do
    double(:group,
      organization: organization,
      covered: covered,
      id: 2,
    )
  end

  let(:members) { described_class.new(group) }
  subject {members}

  its(:covered)      { should eq covered }
  its(:inspect)      { should eq '#<Covered::Group::Members organization_id: 1 group_id: 2>' }
end
