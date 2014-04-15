require 'spec_helper'

describe ApiAccessToken, fixtures: false do

  it { should belong_to(:user) }
  it { should validate_presence_of :user_id }

  it 'auto generates a token' do
    expect(described_class.new.token).to be_present
  end

  it 'validates the uniqueness of token' do
    token1 = described_class.create(user_id: 1, token: 'a')
    token2 = described_class.new(user_id: 1, token: 'a')
    expect(token2).to have(1).error_on :token
  end

end
