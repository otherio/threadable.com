require 'spec_helper'

describe Task do
  it { should belong_to(:project) }
  it { should have_many(:messages) }
  it { should have_and_belong_to_many(:doers) }

  # mass assignment
  [:due_at, :done_at].each do |field|
    it { should allow_mass_assignment_of(field) }
  end
end
