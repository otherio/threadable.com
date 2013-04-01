require 'spec_helper'

describe RegistrationsController do
  context "with login disabled" do
    before do
      Rails.configuration.stub(:login_enabled).and_return(false)
    end

    describe "GET new" do
      it "redirects" do
        get :new, {}
        response.should redirect_to "http://signup.other.io"
      end
    end
  end

  context "with login enabled" do
    before do
      Rails.configuration.stub(:login_enabled).and_return(true)
    end

    describe "GET new" do
      it "does not redirect" do
        get :new, {}
        response.should be_success
      end
    end
  end
end
