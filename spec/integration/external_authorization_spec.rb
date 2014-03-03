require 'spec_helper'

describe ExternalAuthorization do
  describe 'validations' do
    let(:user) {User.last}
    it "requires a unique provider per user" do
      ExternalAuthorization.create(user: user, provider: 'twitterfax', secret: 'foo', token: 'bar')

      auth = ExternalAuthorization.new(user: user, provider: 'twitterfax', secret: 'otherfoo', token: 'otherbar')
      auth.save.should be_false
      auth.errors[:provider].should == ["has already been taken"]
    end
  end
end
