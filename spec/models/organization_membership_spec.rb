require 'spec_helper'

describe OrganizationMembership do
  it { should belong_to :user }
  it { should belong_to :project }
end
