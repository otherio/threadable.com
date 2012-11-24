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
      response.response_code.should == 401
    end

    it "receives an auth token on success" do
      user = @user.email
      pw = 'password'
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)

      # I don't think this HTTP Basic thing is right.  I think it'd be better to change
      # whatever it is that Warden is expecting and supply that.
      
      # don't use user.password since it should get deleted in the model
      xhr :post, :create
      response.response_code.should == 200
      # check for auth token here
    end
  end
end