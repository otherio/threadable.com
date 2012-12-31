require 'spec_helper'

describe Project do

  it { should have_many(:members).through(:project_memberships) }
  it { should have_many(:project_memberships) }
  it { should have_many(:tasks) }
end
