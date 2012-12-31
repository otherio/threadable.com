require 'spec_helper'

describe User do
  it "should have a valid factory" do
    FactoryGirl.build(:user).should be_valid
  end

  it "should include an auth token" do
    FactoryGirl.create(:user).authentication_token.should be_true
  end

end
