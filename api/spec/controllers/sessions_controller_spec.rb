require 'spec_helper'
require 'ruby-debug'

describe SessionsController do
  describe "POST index" do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.create(:user)
    end

    it "fails when bad credentials are supplied" do
      user = @user.email
      pw = 'not the right password'
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)

      xhr :post, :create
      response.status.should == 401
    end

    it "receives an auth token on success" do
      user = @user.email
      pw = 'password'      # don't use user.password since it should get deleted in the model
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)

      xhr :post, :create
      response.status.should == 200
      result = ActiveSupport::JSON.decode(response.body)
      result['user']['email'].should == user
      result['authentication_token'].should be_present
    end
  end
end