require 'spec_helper'

describe GroupMembership, :type => :model do

  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :group }

  it 'validates the uniqueness of group and user' do
    described_class.create!(group_id: 3945, user_id: 89343)

    membership = described_class.new(group_id: 3945, user_id: 89343)
    expect(membership).to be_invalid
    expect(membership.errors.full_messages).to eq ["User already a member of group"]
  end
end
