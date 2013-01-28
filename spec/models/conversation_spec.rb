require 'spec_helper'

describe Conversation do
  it { should have_many(:messages) }
  it { should belong_to(:project) }
end
