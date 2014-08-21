require 'spec_helper'

describe ExternalAuthorization, :type => :request do
  describe 'validations' do
    let(:user) {User.last}
    it "requires a unique provider per user" do
      ExternalAuthorization.create(user: user, provider: 'twitterfax', secret: 'foo', token: 'bar')

      auth = ExternalAuthorization.new(user: user, provider: 'twitterfax', secret: 'otherfoo', token: 'otherbar')
      expect(auth.save).to be_falsey
      expect(auth.errors[:provider]).to eq(["has already been taken"])
    end
  end
end
