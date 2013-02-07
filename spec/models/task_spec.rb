require 'spec_helper'

describe Task do
  it { should belong_to(:project) }
  it { should have_many(:messages) }
  it { should have_and_belong_to_many(:doers) }

  it { should allow_mass_assignment_of(:doers) }
end
