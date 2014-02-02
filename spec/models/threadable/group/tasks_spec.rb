require 'spec_helper'

describe Threadable::Group::Tasks do

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

  its(:organization) { should eq organization }
  its(:threadable)      { should eq threadable }
  its(:inspect)      { should eq '#<Threadable::Group::Tasks organization_id: 1 group_id: 2>' }
end
