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
        sign_in! find_user_by_email_address('bob@ucsd.covered.io')
      end

      it "should show the projects" do
        get :show
        assigns(:projects).should be
        response.should render_template('projects/index')
      end
    end
  end

end
