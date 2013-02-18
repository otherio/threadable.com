require 'spec_helper'

describe User do
  it "should have a valid factory" do
    FactoryGirl.build(:user).should be_valid
  end

  it "should include an auth token" do
    FactoryGirl.create(:user).authentication_token.should be_true
  end

  it "should allow search by identity" do
    user = create(:user)

    User.search_by_identity(user.name).should == [user]
  end

  it "should use the gravatar as the default avatar when none is supplied" do
    user = FactoryGirl.create(:user, email: 'foo@example.com', avatar_url: nil)
    user.avatar_url.should == 'http://gravatar.com/avatar/b48def645758b95537d4424c84d1a9ff.png?s=48'
  end
end
