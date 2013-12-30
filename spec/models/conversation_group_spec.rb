require 'spec_helper'

describe ConversationGroup do
  it { should belong_to :conversation }
  it { should belong_to :group }
end
