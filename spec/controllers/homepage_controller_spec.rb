require 'spec_helper'

describe HomepageController do

  describe "#show" do
    it "should do nothing" do
      get :show
      response.should render_template(:show)
    end
  end

end
