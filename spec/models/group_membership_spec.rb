require 'spec_helper'

describe GroupMembership do

  it { should belong_to :user }
  it { should belong_to :group }

  it 'validates the uniqueness of group and user' do
    described_class.create!(group_id: 3945, user_id: 89343)

    membership = described_class.new(group_id: 3945, user_id: 89343)
    expect(membership).to be_invalid
    expect(membership.errors.full_messages).to eq ["User already a member of group"]
  end
end
