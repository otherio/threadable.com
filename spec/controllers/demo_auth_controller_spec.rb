require 'spec_helper'

describe DemoAuthController do

  let(:alice){ User.find_by_name("Alice Neilson")}

  describe "GET show" do
    it "should redirect to the project conversations page" do
      get :show
      response.should redirect_to project_conversations_path(alice.projects.first)
    end
  end
end

