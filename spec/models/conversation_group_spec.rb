require 'spec_helper'

describe ConversationGroup, :type => :model do
  it { is_expected.to belong_to :conversation }
  it { is_expected.to belong_to :group }
end
