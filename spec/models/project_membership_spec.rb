require 'spec_helper'

describe ProjectMembership do
  it { should belong_to :user }
  it { should belong_to :project }
end
