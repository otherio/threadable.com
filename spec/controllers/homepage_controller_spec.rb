require 'spec_helper'

describe HomepageController do

  describe "#show" do
    context "without a logged in user" do
      it "redirects to sign in" do
        get :show
        response.should redirect_to sign_in_path
      end
    end

    context "with a logged in user" do
      before do
        sign_in! find_user_by_email_address('bob@ucsd.example.com')
      end

      it "should show the organizations" do
        get :show
        assigns(:organizations).should be
        response.should render_template('organizations/index')
      end
    end
  end

end
