require 'spec_helper'

describe Message do
  it { should belong_to(:parent_message) }
  it { should belong_to(:conversation) }
end
