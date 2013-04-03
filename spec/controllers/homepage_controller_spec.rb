require 'spec_helper'

describe HomepageController do

  describe "#show" do
    context "when not signed in" do
      it "should redirect to signup.other.io" do
        get :show
        response.should render_template('homepage/show')
      end
    end
    context "when signed in" do
      before do
        sign_in User.first
      end
      it "should do nothing" do
        get :show
        response.should redirect_to projects_path
      end
    end
  end

end
