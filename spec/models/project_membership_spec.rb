require 'spec_helper'

describe ProjectMembership do
  it { should belong_to :user }
  it { should belong_to :project }
  it { should allow_mass_assignment_of :user }
  it { should allow_mass_assignment_of :project }
  it { should allow_mass_assignment_of :project_id }
  it { should allow_mass_assignment_of :user_id }
  it { should allow_mass_assignment_of :gets_email }
end
