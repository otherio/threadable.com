require 'spec_helper'

describe Task do
  it { should have_one(:project) }
  it { should have_one(:conversation) }
end
