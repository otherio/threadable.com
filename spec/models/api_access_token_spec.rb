require 'spec_helper'

describe ApiAccessToken, type: :model, fixtures: false do

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of :user_id }

  it 'auto generates a token' do
    expect(described_class.new.token).to be_present
  end

  it 'validates the uniqueness of token' do
    token1 = described_class.create(user_id: 1, token: 'a')
    token2 = described_class.new(user_id: 1, token: 'a')
    token2.save
    expect(token2.errors[:token].size).to eq(1)
  end

end
